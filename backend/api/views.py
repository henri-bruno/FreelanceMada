from rest_framework import generics, status, filters
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated, IsAdminUser
from rest_framework.pagination import PageNumberPagination
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import update_session_auth_hash
from django.db.models import Q, Sum, Count, Avg
from django.utils import timezone
from datetime import timedelta
import uuid

from .models import (
    User, FreelanceProfile, Certification, Experience, Portfolio,
    Mission, MissionFichier, Service, ServicePackage, ServiceFAQ, ServiceGalerie,
    Candidature, Contrat, ContratLivraison, Message,
    Paiement, Avis, Notification, Signalement, Categorie, Favori
)
from .serializers import (
    UserSerializer, UserMinimalSerializer, RegisterSerializer, LoginSerializer,
    UserUpdateSerializer, FreelanceProfileSerializer,
    CertificationSerializer, ExperienceSerializer, PortfolioSerializer,
    MissionSerializer, MissionFichierSerializer,
    ServiceSerializer, ServicePackageSerializer, ServiceFAQSerializer, ServiceGalerieSerializer,
    CandidatureSerializer, ContratSerializer, ContratLivraisonSerializer,
    MessageSerializer, PaiementSerializer, AvisSerializer,
    NotificationSerializer, SignalementSerializer, CategorieSerializer, FavoriSerializer,
)


class StandardPagination(PageNumberPagination):
    page_size = 10
    page_size_query_param = 'limit'
    max_page_size = 100


def create_notification(user, type, titre, message, lien=''):
    Notification.objects.create(user=user, type=type, titre=titre, message=message, lien=lien)


# ══════════════════════════════════════════════════════════════
# AUTH
# ══════════════════════════════════════════════════════════════

class RegisterView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            refresh = RefreshToken.for_user(user)
            return Response({
                'user': UserSerializer(user).data,
                'refresh': str(refresh),
                'access': str(refresh.access_token),
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.validated_data
            user.is_online = True
            user.derniere_connexion = timezone.now()
            user.save(update_fields=['is_online', 'derniere_connexion'])
            refresh = RefreshToken.for_user(user)
            return Response({
                'user': UserSerializer(user).data,
                'refresh': str(refresh),
                'access': str(refresh.access_token),
            })
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class LogoutView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        try:
            request.user.is_online = False
            request.user.save(update_fields=['is_online'])
            token = RefreshToken(request.data.get('refresh'))
            token.blacklist()
        except Exception:
            pass
        return Response({'detail': 'Déconnecté.'})


class ChangePasswordView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        old = request.data.get('old_password')
        new = request.data.get('new_password')
        if not request.user.check_password(old):
            return Response({'error': 'Ancien mot de passe incorrect.'}, status=400)
        if not new or len(new) < 8:
            return Response({'error': 'Le nouveau mot de passe doit faire au moins 8 caractères.'}, status=400)
        request.user.set_password(new)
        request.user.save()
        return Response({'detail': 'Mot de passe modifié.'})


# ══════════════════════════════════════════════════════════════
# PROFIL UTILISATEUR
# ══════════════════════════════════════════════════════════════

class MeView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        return Response(UserSerializer(request.user).data)

    def patch(self, request):
        serializer = UserUpdateSerializer(request.user, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(UserSerializer(request.user).data)
        return Response(serializer.errors, status=400)


class UserDetailView(generics.RetrieveAPIView):
    permission_classes = [IsAuthenticated]
    queryset = User.objects.all()
    serializer_class = UserSerializer


class FreelanceListView(generics.ListAPIView):
    permission_classes = [AllowAny]
    serializer_class = UserSerializer
    pagination_class = StandardPagination
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['nom', 'prenom', 'freelance_profile__titre_professionnel', 'freelance_profile__competences', 'ville']
    ordering_fields = ['freelance_profile__note_moyenne', 'date_creation']

    def get_queryset(self):
        qs = User.objects.filter(role='freelance', is_active=True).select_related('freelance_profile')
        disponibilite = self.request.query_params.get('disponibilite')
        if disponibilite:
            qs = qs.filter(freelance_profile__disponibilite=disponibilite)
        competence = self.request.query_params.get('competence')
        if competence:
            qs = qs.filter(freelance_profile__competences__icontains=competence)
        tarif_max = self.request.query_params.get('tarif_max')
        if tarif_max:
            qs = qs.filter(freelance_profile__tarif_horaire__lte=tarif_max)
        ville = self.request.query_params.get('ville')
        if ville:
            qs = qs.filter(ville__icontains=ville)
        return qs


# ─── Certifications ────────────────────────────────────────────────────────

class CertificationView(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = CertificationSerializer

    def get_queryset(self):
        return Certification.objects.filter(freelance=self.request.user)

    def perform_create(self, serializer):
        serializer.save(freelance=self.request.user)


class CertificationDetailView(generics.RetrieveUpdateDestroyAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = CertificationSerializer

    def get_queryset(self):
        return Certification.objects.filter(freelance=self.request.user)


# ─── Expériences ───────────────────────────────────────────────────────────

class ExperienceView(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = ExperienceSerializer

    def get_queryset(self):
        return Experience.objects.filter(freelance=self.request.user)

    def perform_create(self, serializer):
        serializer.save(freelance=self.request.user)


class ExperienceDetailView(generics.RetrieveUpdateDestroyAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = ExperienceSerializer

    def get_queryset(self):
        return Experience.objects.filter(freelance=self.request.user)


# ─── Portfolio ────────────────────────────────────────────────────────────

class PortfolioView(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = PortfolioSerializer

    def get_queryset(self):
        user_id = self.request.query_params.get('user_id', self.request.user.id)
        return Portfolio.objects.filter(freelance_id=user_id)

    def perform_create(self, serializer):
        serializer.save(freelance=self.request.user)


class PortfolioDetailView(generics.RetrieveUpdateDestroyAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = PortfolioSerializer

    def get_queryset(self):
        return Portfolio.objects.filter(freelance=self.request.user)


# ══════════════════════════════════════════════════════════════
# MISSIONS
# ══════════════════════════════════════════════════════════════

class MissionListView(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = MissionSerializer
    pagination_class = StandardPagination
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['titre', 'description', 'categorie', 'competences_requises']
    ordering_fields = ['date_creation', 'budget', 'deadline']

    def get_queryset(self):
        qs = Mission.objects.select_related('client', 'freelance_assigne').prefetch_related('candidatures')
        statut = self.request.query_params.get('statut')
        if statut:
            qs = qs.filter(statut=statut)
        categorie = self.request.query_params.get('categorie')
        if categorie:
            qs = qs.filter(categorie__icontains=categorie)
        budget_max = self.request.query_params.get('budget_max')
        if budget_max:
            qs = qs.filter(budget__lte=budget_max)
        niveau = self.request.query_params.get('niveau')
        if niveau:
            qs = qs.filter(niveau_experience=niveau)
        mine = self.request.query_params.get('mine')
        if mine == '1':
            if self.request.user.role == 'client':
                qs = qs.filter(client=self.request.user)
            else:
                qs = qs.filter(freelance_assigne=self.request.user)
        else:
            qs = qs.filter(statut='en_attente')
        return qs.order_by('-date_creation')

    def perform_create(self, serializer):
        mission = serializer.save(client=self.request.user)
        return mission


class MissionDetailView(generics.RetrieveUpdateDestroyAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = MissionSerializer

    def get_queryset(self):
        return Mission.objects.all()

    def retrieve(self, request, *args, **kwargs):
        instance = self.get_object()
        instance.nb_vues += 1
        instance.save(update_fields=['nb_vues'])
        return Response(self.get_serializer(instance).data)

    def update(self, request, *args, **kwargs):
        instance = self.get_object()
        if instance.client != request.user and not request.user.is_staff:
            return Response({'error': 'Non autorisé.'}, status=403)
        return super().update(request, *args, **kwargs)

    def destroy(self, request, *args, **kwargs):
        instance = self.get_object()
        if instance.client != request.user and not request.user.is_staff:
            return Response({'error': 'Non autorisé.'}, status=403)
        return super().destroy(request, *args, **kwargs)


class MissionFichierUploadView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, mission_id):
        mission = Mission.objects.get(pk=mission_id, client=request.user)
        fichier = request.FILES.get('fichier')
        if not fichier:
            return Response({'error': 'Fichier manquant.'}, status=400)
        mf = MissionFichier.objects.create(
            mission=mission,
            fichier=fichier,
            nom_original=fichier.name,
            taille=fichier.size,
        )
        return Response(MissionFichierSerializer(mf).data, status=201)


# ══════════════════════════════════════════════════════════════
# SERVICES
# ══════════════════════════════════════════════════════════════

class ServiceListView(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = ServiceSerializer
    pagination_class = StandardPagination
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['titre', 'description', 'categorie', 'tags']
    ordering_fields = ['note_moyenne', 'nb_ventes', 'date_creation']

    def get_queryset(self):
        qs = Service.objects.filter(actif=True).select_related('freelance')
        categorie = self.request.query_params.get('categorie')
        if categorie:
            qs = qs.filter(categorie__icontains=categorie)
        freelance_id = self.request.query_params.get('freelance_id')
        if freelance_id:
            qs = qs.filter(freelance_id=freelance_id)
        mine = self.request.query_params.get('mine')
        if mine == '1':
            qs = Service.objects.filter(freelance=self.request.user)
        return qs.order_by('-date_creation')


class ServiceDetailView(generics.RetrieveUpdateDestroyAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = ServiceSerializer
    queryset = Service.objects.all()

    def update(self, request, *args, **kwargs):
        instance = self.get_object()
        if instance.freelance != request.user and not request.user.is_staff:
            return Response({'error': 'Non autorisé.'}, status=403)
        return super().update(request, *args, **kwargs)

    def destroy(self, request, *args, **kwargs):
        instance = self.get_object()
        if instance.freelance != request.user and not request.user.is_staff:
            return Response({'error': 'Non autorisé.'}, status=403)
        return super().destroy(request, *args, **kwargs)


class ServicePackageView(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = ServicePackageSerializer

    def get_queryset(self):
        return ServicePackage.objects.filter(service_id=self.kwargs['service_id'])

    def perform_create(self, serializer):
        service = Service.objects.get(pk=self.kwargs['service_id'], freelance=self.request.user)
        serializer.save(service=service)


# ══════════════════════════════════════════════════════════════
# CANDIDATURES
# ══════════════════════════════════════════════════════════════

class CandidatureListView(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = CandidatureSerializer

    def get_queryset(self):
        mission_id = self.request.query_params.get('mission_id')
        if mission_id:
            return Candidature.objects.filter(mission_id=mission_id, mission__client=self.request.user)
        return Candidature.objects.filter(freelance=self.request.user)

    def perform_create(self, serializer):
        cand = serializer.save(freelance=self.request.user)
        create_notification(
            cand.mission.client,
            'candidature',
            'Nouvelle candidature',
            f'{self.request.user.nom} a postulé à votre mission "{cand.mission.titre}".',
            f'/missions/{cand.mission.id}',
        )


class CandidatureDetailView(generics.RetrieveUpdateDestroyAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = CandidatureSerializer

    def get_queryset(self):
        return Candidature.objects.all()

    def update(self, request, *args, **kwargs):
        instance = self.get_object()
        nouveau_statut = request.data.get('statut')
        # seul le client peut accepter/refuser
        if nouveau_statut in ['accepte', 'refuse'] and instance.mission.client != request.user:
            return Response({'error': 'Non autorisé.'}, status=403)
        result = super().update(request, *args, **kwargs)
        if nouveau_statut == 'accepte':
            instance.mission.freelance_assigne = instance.freelance
            instance.mission.statut = 'en_cours'
            instance.mission.save()
            create_notification(
                instance.freelance,
                'candidature',
                'Candidature acceptée',
                f'Votre candidature pour "{instance.mission.titre}" a été acceptée !',
                f'/contrats',
            )
        return result


# ══════════════════════════════════════════════════════════════
# CONTRATS
# ══════════════════════════════════════════════════════════════

class ContratListView(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = ContratSerializer

    def get_queryset(self):
        user = self.request.user
        return Contrat.objects.filter(Q(client=user) | Q(freelance=user)).order_by('-date_creation')


class ContratDetailView(generics.RetrieveUpdateAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = ContratSerializer

    def get_queryset(self):
        user = self.request.user
        return Contrat.objects.filter(Q(client=user) | Q(freelance=user))

    def patch(self, request, *args, **kwargs):
        instance = self.get_object()
        action = request.data.get('action')
        if action == 'signer_client' and instance.client == request.user:
            instance.signe_client = True
        elif action == 'signer_freelance' and instance.freelance == request.user:
            instance.signe_freelance = True
        elif action == 'valider' and instance.client == request.user:
            instance.statut = 'valide'
            instance.date_validation = timezone.now()
        elif action == 'livrer' and instance.freelance == request.user:
            instance.statut = 'livre'
            instance.date_livraison = timezone.now()
        else:
            return super().partial_update(request, *args, **kwargs)

        if instance.signe_client and instance.signe_freelance and instance.statut == 'en_attente':
            instance.statut = 'en_cours'
            instance.date_debut = timezone.now().date()

        instance.save()
        return Response(ContratSerializer(instance).data)


class ContratLivraisonView(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = ContratLivraisonSerializer

    def get_queryset(self):
        return ContratLivraison.objects.filter(contrat_id=self.kwargs['contrat_id'])

    def perform_create(self, serializer):
        contrat = Contrat.objects.get(pk=self.kwargs['contrat_id'])
        livraison = serializer.save(contrat=contrat)
        create_notification(
            contrat.client,
            'contrat',
            'Nouvelle livraison',
            f'Le freelance a soumis une livraison pour votre contrat "{contrat.titre}".',
        )


# ══════════════════════════════════════════════════════════════
# MESSAGES
# ══════════════════════════════════════════════════════════════

class ConversationListView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        msg_qs = Message.objects.filter(
            Q(sender=user) | Q(receiver=user)
        ).order_by('-date')

        seen = set()
        conversations = []
        for msg in msg_qs:
            other = msg.receiver if msg.sender == user else msg.sender
            if other.id not in seen:
                seen.add(other.id)
                unread = Message.objects.filter(sender=other, receiver=user, lu=False).count()
                conversations.append({
                    'user': UserMinimalSerializer(other).data,
                    'dernier_message': MessageSerializer(msg).data,
                    'nb_non_lus': unread,
                })
        return Response(conversations)


class MessageListView(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = MessageSerializer
    pagination_class = StandardPagination

    def get_queryset(self):
        other_id = self.kwargs.get('user_id')
        user = self.request.user
        qs = Message.objects.filter(
            Q(sender=user, receiver_id=other_id) | Q(sender_id=other_id, receiver=user)
        ).order_by('date')
        Message.objects.filter(sender_id=other_id, receiver=user, lu=False).update(lu=True)
        return qs

    def perform_create(self, serializer):
        serializer.save(sender=self.request.user)
        receiver = User.objects.get(pk=self.request.data.get('receiver'))
        create_notification(
            receiver,
            'message',
            'Nouveau message',
            f'{self.request.user.nom} vous a envoyé un message.',
        )


class MessageDetailView(generics.RetrieveUpdateDestroyAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = MessageSerializer

    def get_queryset(self):
        return Message.objects.filter(sender=self.request.user)

    def patch(self, request, *args, **kwargs):
        instance = self.get_object()
        contenu = request.data.get('contenu')
        if contenu:
            instance.contenu = contenu
            instance.modifie = True
            instance.save()
        return Response(MessageSerializer(instance).data)

    def delete(self, request, *args, **kwargs):
        instance = self.get_object()
        instance.supprime = True
        instance.contenu = 'Message supprimé'
        instance.save()
        return Response(status=204)


# ══════════════════════════════════════════════════════════════
# PAIEMENTS
# ══════════════════════════════════════════════════════════════

class PaiementListView(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = PaiementSerializer

    def get_queryset(self):
        user = self.request.user
        return Paiement.objects.filter(Q(client=user) | Q(freelance=user)).order_by('-date')


class PaiementDetailView(generics.RetrieveAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = PaiementSerializer

    def get_queryset(self):
        user = self.request.user
        return Paiement.objects.filter(Q(client=user) | Q(freelance=user))


# ══════════════════════════════════════════════════════════════
# AVIS
# ══════════════════════════════════════════════════════════════

class AvisListView(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = AvisSerializer

    def get_queryset(self):
        cible_id = self.request.query_params.get('cible_id')
        service_id = self.request.query_params.get('service_id')
        if cible_id:
            return Avis.objects.filter(cible_id=cible_id).order_by('-date')
        if service_id:
            return Avis.objects.filter(service_id=service_id).order_by('-date')
        return Avis.objects.filter(auteur=self.request.user).order_by('-date')


# ══════════════════════════════════════════════════════════════
# NOTIFICATIONS
# ══════════════════════════════════════════════════════════════

class NotificationListView(generics.ListAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = NotificationSerializer
    pagination_class = StandardPagination

    def get_queryset(self):
        return Notification.objects.filter(user=self.request.user).order_by('-date')


class NotificationMarkReadView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, pk=None):
        if pk:
            Notification.objects.filter(pk=pk, user=request.user).update(lu=True)
        else:
            Notification.objects.filter(user=request.user, lu=False).update(lu=True)
        return Response({'detail': 'Marqué comme lu.'})


# ══════════════════════════════════════════════════════════════
# DASHBOARD
# ══════════════════════════════════════════════════════════════

class DashboardView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        now = timezone.now()
        debut_mois = now.replace(day=1, hour=0, minute=0, second=0)

        if user.role == 'client':
            missions = Mission.objects.filter(client=user)
            data = {
                'total_missions': missions.count(),
                'missions_en_cours': missions.filter(statut='en_cours').count(),
                'missions_terminees': missions.filter(statut='termine').count(),
                'total_depense': Paiement.objects.filter(client=user, statut='paye').aggregate(t=Sum('montant'))['t'] or 0,
                'depense_mois': Paiement.objects.filter(client=user, statut='paye', date__gte=debut_mois).aggregate(t=Sum('montant'))['t'] or 0,
                'nb_candidatures_recues': Candidature.objects.filter(mission__client=user).count(),
                'notifications_non_lues': Notification.objects.filter(user=user, lu=False).count(),
                'missions_recentes': MissionSerializer(missions.order_by('-date_creation')[:5], many=True).data,
            }
        elif user.role == 'freelance':
            contrats = Contrat.objects.filter(freelance=user)
            try:
                profile = user.freelance_profile
            except Exception:
                profile = None
            data = {
                'note_moyenne': profile.note_moyenne if profile else 0,
                'nb_avis': profile.nb_avis if profile else 0,
                'missions_completees': contrats.filter(statut='valide').count(),
                'missions_en_cours': contrats.filter(statut='en_cours').count(),
                'total_revenus': Paiement.objects.filter(freelance=user, statut='paye').aggregate(t=Sum('montant_net'))['t'] or 0,
                'revenus_mois': Paiement.objects.filter(freelance=user, statut='paye', date__gte=debut_mois).aggregate(t=Sum('montant_net'))['t'] or 0,
                'candidatures_en_attente': Candidature.objects.filter(freelance=user, statut='en_attente').count(),
                'nb_services': Service.objects.filter(freelance=user, actif=True).count(),
                'notifications_non_lues': Notification.objects.filter(user=user, lu=False).count(),
                'contrats_recents': ContratSerializer(contrats.order_by('-date_creation')[:5], many=True).data,
            }
        else:
            data = {
                'total_users': User.objects.count(),
                'total_missions': Mission.objects.count(),
                'total_services': Service.objects.count(),
                'total_paiements': Paiement.objects.filter(statut='paye').aggregate(t=Sum('montant'))['t'] or 0,
                'signalements_en_attente': Signalement.objects.filter(statut='en_attente').count(),
            }

        return Response(data)


# ══════════════════════════════════════════════════════════════
# CATÉGORIES
# ══════════════════════════════════════════════════════════════

class CategorieListView(generics.ListAPIView):
    permission_classes = [AllowAny]
    serializer_class = CategorieSerializer

    def get_queryset(self):
        return Categorie.objects.filter(actif=True, parent=None)


# ══════════════════════════════════════════════════════════════
# FAVORIS
# ══════════════════════════════════════════════════════════════

class FavoriListView(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = FavoriSerializer

    def get_queryset(self):
        return Favori.objects.filter(user=self.request.user)


class FavoriDetailView(generics.DestroyAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = FavoriSerializer

    def get_queryset(self):
        return Favori.objects.filter(user=self.request.user)


# ══════════════════════════════════════════════════════════════
# SIGNALEMENTS
# ══════════════════════════════════════════════════════════════

class SignalementView(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = SignalementSerializer

    def get_queryset(self):
        if self.request.user.is_staff:
            return Signalement.objects.all().order_by('-date')
        return Signalement.objects.filter(signaleur=self.request.user)


# ══════════════════════════════════════════════════════════════
# RECHERCHE GLOBALE
# ══════════════════════════════════════════════════════════════

class SearchView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        q = request.query_params.get('q', '').strip()
        if not q:
            return Response({'missions': [], 'services': [], 'freelances': []})

        missions = Mission.objects.filter(
            Q(titre__icontains=q) | Q(description__icontains=q) | Q(categorie__icontains=q),
            statut='en_attente'
        )[:5]
        services = Service.objects.filter(
            Q(titre__icontains=q) | Q(description__icontains=q) | Q(tags__icontains=q),
            actif=True
        )[:5]
        freelances = User.objects.filter(
            Q(nom__icontains=q) | Q(prenom__icontains=q) |
            Q(freelance_profile__titre_professionnel__icontains=q) |
            Q(freelance_profile__competences__icontains=q),
            role='freelance'
        )[:5]

        return Response({
            'missions': MissionSerializer(missions, many=True).data,
            'services': ServiceSerializer(services, many=True).data,
            'freelances': UserMinimalSerializer(freelances, many=True).data,
        })
