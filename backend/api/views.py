from rest_framework import generics, status, filters
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework_simplejwt.tokens import RefreshToken
from django.db.models import Q

from .models import User, Mission, Candidature, Message, Paiement, Avis
from .serializers import (
    RegisterSerializer, LoginSerializer, UserSerializer, UserUpdateSerializer,
    MissionSerializer, CandidatureSerializer, MessageSerializer,
    PaiementSerializer, AvisSerializer
)


class RegisterView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            refresh = RefreshToken.for_user(user)
            return Response({
                'user': UserSerializer(user).data,
                'access': str(refresh.access_token),
                'refresh': str(refresh),
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.validated_data['user']
            refresh = RefreshToken.for_user(user)
            return Response({
                'user': UserSerializer(user).data,
                'access': str(refresh.access_token),
                'refresh': str(refresh),
            })
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class ProfileView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        serializer = UserSerializer(request.user)
        return Response(serializer.data)

    def put(self, request):
        serializer = UserUpdateSerializer(request.user, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(UserSerializer(request.user).data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class MissionListCreateView(generics.ListCreateAPIView):
    serializer_class = MissionSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['titre', 'description', 'categorie']
    ordering_fields = ['date_creation', 'budget', 'deadline']

    def get_queryset(self):
        queryset = Mission.objects.all()
        statut = self.request.query_params.get('statut')
        categorie = self.request.query_params.get('categorie')
        budget_min = self.request.query_params.get('budget_min')
        budget_max = self.request.query_params.get('budget_max')

        if statut:
            queryset = queryset.filter(statut=statut)
        if categorie:
            queryset = queryset.filter(categorie__icontains=categorie)
        if budget_min:
            queryset = queryset.filter(budget__gte=budget_min)
        if budget_max:
            queryset = queryset.filter(budget__lte=budget_max)
        return queryset


class MissionDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Mission.objects.all()
    serializer_class = MissionSerializer
    permission_classes = [IsAuthenticated]

    def update(self, request, *args, **kwargs):
        mission = self.get_object()
        if mission.client != request.user:
            return Response({'detail': 'Non autorisé.'}, status=status.HTTP_403_FORBIDDEN)
        return super().update(request, *args, **kwargs)

    def destroy(self, request, *args, **kwargs):
        mission = self.get_object()
        if mission.client != request.user:
            return Response({'detail': 'Non autorisé.'}, status=status.HTTP_403_FORBIDDEN)
        return super().destroy(request, *args, **kwargs)


class ApplyView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        if request.user.role != 'freelance':
            return Response({'detail': 'Seuls les freelances peuvent postuler.'}, status=status.HTTP_403_FORBIDDEN)
        serializer = CandidatureSerializer(data=request.data, context={'request': request})
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class MissionApplicationsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, pk):
        candidatures = Candidature.objects.filter(mission_id=pk)
        serializer = CandidatureSerializer(candidatures, many=True)
        return Response(serializer.data)

    def patch(self, request, pk):
        """Accept or refuse a candidature"""
        candidature_id = request.data.get('candidature_id')
        new_statut = request.data.get('statut')
        try:
            candidature = Candidature.objects.get(id=candidature_id, mission_id=pk)
            if candidature.mission.client != request.user:
                return Response({'detail': 'Non autorisé.'}, status=status.HTTP_403_FORBIDDEN)
            candidature.statut = new_statut
            candidature.save()
            if new_statut == 'accepte':
                candidature.mission.statut = 'en_cours'
                candidature.mission.save()
            return Response(CandidatureSerializer(candidature).data)
        except Candidature.DoesNotExist:
            return Response({'detail': 'Candidature introuvable.'}, status=status.HTTP_404_NOT_FOUND)


class MessageListCreateView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        other_user_id = request.query_params.get('user_id')
        if other_user_id:
            messages = Message.objects.filter(
                Q(sender=request.user, receiver_id=other_user_id) |
                Q(sender_id=other_user_id, receiver=request.user)
            )
        else:
            messages = Message.objects.filter(
                Q(sender=request.user) | Q(receiver=request.user)
            )
        serializer = MessageSerializer(messages, many=True)
        return Response(serializer.data)

    def post(self, request):
        serializer = MessageSerializer(data=request.data, context={'request': request})
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class ConversationListView(APIView):
    """Liste des utilisateurs avec qui l'utilisateur a une conversation"""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        sent_to = Message.objects.filter(sender=request.user).values_list('receiver_id', flat=True)
        received_from = Message.objects.filter(receiver=request.user).values_list('sender_id', flat=True)
        user_ids = set(list(sent_to) + list(received_from))
        users = User.objects.filter(id__in=user_ids)
        serializer = UserSerializer(users, many=True)
        return Response(serializer.data)


class PaiementView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = PaiementSerializer(data=request.data)
        if serializer.is_valid():
            paiement = serializer.save()
            paiement.statut = 'paye'
            paiement.save()
            mission = paiement.mission
            mission.statut = 'termine'
            mission.save()
            return Response(PaiementSerializer(paiement).data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def get(self, request):
        paiements = Paiement.objects.filter(
            Q(mission__client=request.user) | Q(mission__candidatures__freelance=request.user)
        ).distinct()
        serializer = PaiementSerializer(paiements, many=True)
        return Response(serializer.data)


class AvisView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = AvisSerializer(data=request.data, context={'request': request})
        if serializer.is_valid():
            avis = serializer.save()
            # Recalcule note moyenne du freelance
            mission = avis.mission
            candidature_acceptee = mission.candidatures.filter(statut='accepte').first()
            if candidature_acceptee:
                freelance = candidature_acceptee.freelance
                if hasattr(freelance, 'freelance_profile'):
                    all_avis = Avis.objects.filter(
                        mission__candidatures__freelance=freelance,
                        mission__candidatures__statut='accepte'
                    )
                    if all_avis.exists():
                        avg = sum(a.note for a in all_avis) / all_avis.count()
                        freelance.freelance_profile.note_moyenne = round(avg, 2)
                        freelance.freelance_profile.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class DashboardView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        if user.role == 'client':
            missions = Mission.objects.filter(client=user)
            data = {
                'total_missions': missions.count(),
                'missions_en_attente': missions.filter(statut='en_attente').count(),
                'missions_en_cours': missions.filter(statut='en_cours').count(),
                'missions_terminees': missions.filter(statut='termine').count(),
                'total_candidatures': Candidature.objects.filter(mission__client=user).count(),
            }
        elif user.role == 'freelance':
            candidatures = Candidature.objects.filter(freelance=user)
            data = {
                'total_candidatures': candidatures.count(),
                'candidatures_acceptees': candidatures.filter(statut='accepte').count(),
                'missions_en_cours': candidatures.filter(statut='accepte', mission__statut='en_cours').count(),
                'missions_terminees': candidatures.filter(statut='accepte', mission__statut='termine').count(),
                'note_moyenne': user.freelance_profile.note_moyenne if hasattr(user, 'freelance_profile') else 0,
            }
        else:
            data = {
                'total_users': User.objects.count(),
                'total_missions': Mission.objects.count(),
                'total_paiements': Paiement.objects.filter(statut='paye').count(),
            }
        return Response(data)
