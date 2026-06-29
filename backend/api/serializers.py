from rest_framework import serializers
from django.contrib.auth import authenticate
from .models import (
    User, FreelanceProfile, Certification, Experience, Portfolio, PortfolioMedia,
    Mission, MissionFichier, Service, ServicePackage, ServiceFAQ, ServiceGalerie,
    Candidature, Contrat, ContratLivraison, Message, MessageReaction,
    Paiement, Avis, Notification, Signalement, Categorie, Favori
)


class FreelanceProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = FreelanceProfile
        fields = [
            'competences', 'bio', 'bio_courte', 'experience', 'note_moyenne',
            'nb_avis', 'tarif_horaire', 'disponibilite', 'titre_professionnel',
            'linkedin', 'github', 'website', 'twitter',
            'missions_completees', 'taux_reussite',
        ]


class CertificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Certification
        fields = '__all__'
        read_only_fields = ['freelance']


class ExperienceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Experience
        fields = '__all__'
        read_only_fields = ['freelance']


class PortfolioMediaSerializer(serializers.ModelSerializer):
    class Meta:
        model = PortfolioMedia
        fields = '__all__'


class PortfolioSerializer(serializers.ModelSerializer):
    medias = PortfolioMediaSerializer(many=True, read_only=True)

    class Meta:
        model = Portfolio
        fields = '__all__'
        read_only_fields = ['freelance', 'date_creation']


class UserMinimalSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'nom', 'prenom', 'email', 'photo', 'role', 'is_verified', 'is_online', 'ville', 'pays']


class UserSerializer(serializers.ModelSerializer):
    freelance_profile = FreelanceProfileSerializer(read_only=True)
    certifications = CertificationSerializer(many=True, read_only=True)
    experiences = ExperienceSerializer(many=True, read_only=True)
    portfolio = PortfolioSerializer(many=True, read_only=True)
    nb_missions = serializers.SerializerMethodField()
    nb_services = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = [
            'id', 'nom', 'prenom', 'email', 'telephone', 'photo', 'photo_couverture',
            'role', 'is_verified', 'is_online', 'derniere_connexion',
            'ville', 'pays', 'date_creation',
            'freelance_profile', 'certifications', 'experiences', 'portfolio',
            'nb_missions', 'nb_services',
        ]
        read_only_fields = ['id', 'date_creation', 'is_verified']

    def get_nb_missions(self, obj):
        if obj.role == 'client':
            return obj.missions_client.count()
        return obj.missions_assignees.count()

    def get_nb_services(self, obj):
        if obj.role == 'freelance':
            return obj.services.filter(actif=True).count()
        return 0


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)

    class Meta:
        model = User
        fields = ['id', 'nom', 'prenom', 'email', 'password', 'telephone', 'role', 'ville', 'pays']

    def create(self, validated_data):
        password = validated_data.pop('password')
        user = User(**validated_data)
        user.set_password(password)
        user.save()
        if user.role == 'freelance':
            FreelanceProfile.objects.create(user=user)
        return user


class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField()

    def validate(self, data):
        user = authenticate(username=data['email'], password=data['password'])
        if not user:
            raise serializers.ValidationError('Email ou mot de passe incorrect.')
        if not user.is_active:
            raise serializers.ValidationError('Compte désactivé.')
        return user


class UserUpdateSerializer(serializers.ModelSerializer):
    freelance_profile = FreelanceProfileSerializer(required=False)

    class Meta:
        model = User
        fields = [
            'nom', 'prenom', 'telephone', 'photo', 'photo_couverture',
            'ville', 'pays', 'freelance_profile',
        ]

    def update(self, instance, validated_data):
        profile_data = validated_data.pop('freelance_profile', None)
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        if profile_data and instance.role == 'freelance':
            profile, _ = FreelanceProfile.objects.get_or_create(user=instance)
            for attr, value in profile_data.items():
                setattr(profile, attr, value)
            profile.save()
        return instance


# ─── Mission ────────────────────────────────────────────────────────────────

class MissionFichierSerializer(serializers.ModelSerializer):
    class Meta:
        model = MissionFichier
        fields = '__all__'
        read_only_fields = ['mission']


class MissionSerializer(serializers.ModelSerializer):
    client_nom = serializers.CharField(source='client.nom', read_only=True)
    client_photo = serializers.ImageField(source='client.photo', read_only=True)
    freelance_nom = serializers.SerializerMethodField()
    nb_candidatures = serializers.SerializerMethodField()
    fichiers = MissionFichierSerializer(many=True, read_only=True)

    class Meta:
        model = Mission
        fields = [
            'id', 'client', 'client_nom', 'client_photo',
            'freelance_assigne', 'freelance_nom',
            'titre', 'description', 'budget_min', 'budget',
            'deadline', 'categorie', 'competences_requises',
            'niveau_experience', 'statut', 'nb_vues',
            'date_creation', 'nb_candidatures', 'fichiers',
        ]
        read_only_fields = ['client', 'date_creation', 'nb_vues']

    def get_nb_candidatures(self, obj):
        return obj.candidatures.count()

    def get_freelance_nom(self, obj):
        return obj.freelance_assigne.nom if obj.freelance_assigne else None

    def create(self, validated_data):
        validated_data['client'] = self.context['request'].user
        return super().create(validated_data)


# ─── Service ────────────────────────────────────────────────────────────────

class ServicePackageSerializer(serializers.ModelSerializer):
    class Meta:
        model = ServicePackage
        fields = '__all__'
        read_only_fields = ['service']


class ServiceFAQSerializer(serializers.ModelSerializer):
    class Meta:
        model = ServiceFAQ
        fields = '__all__'
        read_only_fields = ['service']


class ServiceGalerieSerializer(serializers.ModelSerializer):
    class Meta:
        model = ServiceGalerie
        fields = '__all__'
        read_only_fields = ['service']


class ServiceSerializer(serializers.ModelSerializer):
    freelance_nom = serializers.CharField(source='freelance.nom', read_only=True)
    freelance_photo = serializers.ImageField(source='freelance.photo', read_only=True)
    freelance_note = serializers.SerializerMethodField()
    packages = ServicePackageSerializer(many=True, read_only=True)
    faqs = ServiceFAQSerializer(many=True, read_only=True)
    galerie = ServiceGalerieSerializer(many=True, read_only=True)

    class Meta:
        model = Service
        fields = [
            'id', 'freelance', 'freelance_nom', 'freelance_photo', 'freelance_note',
            'titre', 'description', 'categorie', 'image_principale',
            'video_presentation', 'tags', 'actif',
            'nb_ventes', 'note_moyenne', 'date_creation',
            'packages', 'faqs', 'galerie',
        ]
        read_only_fields = ['freelance', 'nb_ventes', 'note_moyenne', 'date_creation']

    def get_freelance_note(self, obj):
        try:
            return obj.freelance.freelance_profile.note_moyenne
        except Exception:
            return 0.0

    def create(self, validated_data):
        validated_data['freelance'] = self.context['request'].user
        return super().create(validated_data)


# ─── Candidature ────────────────────────────────────────────────────────────

class CandidatureSerializer(serializers.ModelSerializer):
    freelance_nom = serializers.CharField(source='freelance.nom', read_only=True)
    freelance_photo = serializers.ImageField(source='freelance.photo', read_only=True)
    freelance_note = serializers.SerializerMethodField()
    mission_titre = serializers.CharField(source='mission.titre', read_only=True)

    class Meta:
        model = Candidature
        fields = [
            'id', 'mission', 'mission_titre',
            'freelance', 'freelance_nom', 'freelance_photo', 'freelance_note',
            'message', 'prix_propose', 'delai', 'statut', 'date_candidature',
        ]
        read_only_fields = ['freelance', 'statut', 'date_candidature']

    def get_freelance_note(self, obj):
        try:
            return obj.freelance.freelance_profile.note_moyenne
        except Exception:
            return 0.0

    def create(self, validated_data):
        validated_data['freelance'] = self.context['request'].user
        return super().create(validated_data)


# ─── Contrat ────────────────────────────────────────────────────────────────

class ContratLivraisonSerializer(serializers.ModelSerializer):
    class Meta:
        model = ContratLivraison
        fields = '__all__'
        read_only_fields = ['date']


class ContratSerializer(serializers.ModelSerializer):
    client_nom = serializers.CharField(source='client.nom', read_only=True)
    freelance_nom = serializers.CharField(source='freelance.nom', read_only=True)
    client_photo = serializers.ImageField(source='client.photo', read_only=True)
    freelance_photo = serializers.ImageField(source='freelance.photo', read_only=True)
    livraisons = ContratLivraisonSerializer(many=True, read_only=True)

    class Meta:
        model = Contrat
        fields = '__all__'
        read_only_fields = ['date_creation']


# ─── Message ────────────────────────────────────────────────────────────────

class MessageReactionSerializer(serializers.ModelSerializer):
    user_nom = serializers.CharField(source='user.nom', read_only=True)

    class Meta:
        model = MessageReaction
        fields = '__all__'
        read_only_fields = ['user']


class MessageSerializer(serializers.ModelSerializer):
    sender_nom = serializers.CharField(source='sender.nom', read_only=True)
    sender_photo = serializers.ImageField(source='sender.photo', read_only=True)
    receiver_nom = serializers.CharField(source='receiver.nom', read_only=True)
    reactions = MessageReactionSerializer(many=True, read_only=True)
    reponse_a_contenu = serializers.SerializerMethodField()

    class Meta:
        model = Message
        fields = [
            'id', 'sender', 'sender_nom', 'sender_photo',
            'receiver', 'receiver_nom',
            'contenu', 'type', 'fichier', 'nom_fichier', 'taille_fichier',
            'date', 'lu', 'modifie', 'supprime',
            'reponse_a', 'reponse_a_contenu', 'reactions',
        ]
        read_only_fields = ['sender', 'date', 'modifie']

    def get_reponse_a_contenu(self, obj):
        if obj.reponse_a:
            return {
                'id': obj.reponse_a.id,
                'contenu': obj.reponse_a.contenu,
                'sender_nom': obj.reponse_a.sender.nom,
            }
        return None

    def create(self, validated_data):
        validated_data['sender'] = self.context['request'].user
        return super().create(validated_data)


# ─── Paiement ───────────────────────────────────────────────────────────────

class PaiementSerializer(serializers.ModelSerializer):
    mission_titre = serializers.SerializerMethodField()
    contrat_titre = serializers.SerializerMethodField()

    class Meta:
        model = Paiement
        fields = '__all__'
        read_only_fields = ['date', 'reference']

    def get_mission_titre(self, obj):
        return obj.mission.titre if obj.mission else None

    def get_contrat_titre(self, obj):
        return obj.contrat.titre if obj.contrat else None


# ─── Avis ───────────────────────────────────────────────────────────────────

class AvisSerializer(serializers.ModelSerializer):
    auteur_nom = serializers.CharField(source='auteur.nom', read_only=True)
    auteur_photo = serializers.ImageField(source='auteur.photo', read_only=True)

    class Meta:
        model = Avis
        fields = '__all__'
        read_only_fields = ['auteur', 'date']

    def create(self, validated_data):
        validated_data['auteur'] = self.context['request'].user
        avis = super().create(validated_data)
        if avis.cible and avis.cible.role == 'freelance':
            try:
                profile = avis.cible.freelance_profile
                avis_list = Avis.objects.filter(cible=avis.cible)
                profile.note_moyenne = sum(a.note for a in avis_list) / avis_list.count()
                profile.nb_avis = avis_list.count()
                profile.save()
            except Exception:
                pass
        return avis


# ─── Notification ───────────────────────────────────────────────────────────

class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = '__all__'
        read_only_fields = ['user', 'date']


# ─── Autres ─────────────────────────────────────────────────────────────────

class SignalementSerializer(serializers.ModelSerializer):
    class Meta:
        model = Signalement
        fields = '__all__'
        read_only_fields = ['signaleur', 'date', 'statut']

    def create(self, validated_data):
        validated_data['signaleur'] = self.context['request'].user
        return super().create(validated_data)


class CategorieSerializer(serializers.ModelSerializer):
    sous_categories = serializers.SerializerMethodField()

    class Meta:
        model = Categorie
        fields = '__all__'

    def get_sous_categories(self, obj):
        return CategorieSerializer(obj.sous_categories.filter(actif=True), many=True).data


class FavoriSerializer(serializers.ModelSerializer):
    class Meta:
        model = Favori
        fields = '__all__'
        read_only_fields = ['user', 'date']

    def create(self, validated_data):
        validated_data['user'] = self.context['request'].user
        return super().create(validated_data)
