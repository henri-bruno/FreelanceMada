from rest_framework import serializers
from django.contrib.auth import authenticate
from .models import User, FreelanceProfile, Mission, Candidature, Message, Paiement, Avis


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=6)

    class Meta:
        model = User
        fields = ['id', 'nom', 'email', 'password', 'telephone', 'role']

    def create(self, validated_data):
        user = User.objects.create_user(
            email=validated_data['email'],
            nom=validated_data['nom'],
            password=validated_data['password'],
            telephone=validated_data.get('telephone', ''),
            role=validated_data.get('role', 'client'),
        )
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
        data['user'] = user
        return data


class FreelanceProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = FreelanceProfile
        fields = ['competences', 'bio', 'experience', 'note_moyenne']


class UserSerializer(serializers.ModelSerializer):
    freelance_profile = FreelanceProfileSerializer(read_only=True)

    class Meta:
        model = User
        fields = ['id', 'nom', 'email', 'telephone', 'photo', 'role', 'date_creation', 'freelance_profile']
        read_only_fields = ['id', 'date_creation']


class UserUpdateSerializer(serializers.ModelSerializer):
    freelance_profile = FreelanceProfileSerializer(required=False)

    class Meta:
        model = User
        fields = ['nom', 'telephone', 'photo', 'freelance_profile']

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


class MissionSerializer(serializers.ModelSerializer):
    client_nom = serializers.CharField(source='client.nom', read_only=True)
    nb_candidatures = serializers.SerializerMethodField()

    class Meta:
        model = Mission
        fields = [
            'id', 'client', 'client_nom', 'titre', 'description',
            'budget', 'deadline', 'categorie', 'statut', 'date_creation', 'nb_candidatures'
        ]
        read_only_fields = ['id', 'client', 'date_creation']

    def get_nb_candidatures(self, obj):
        return obj.candidatures.count()

    def create(self, validated_data):
        validated_data['client'] = self.context['request'].user
        return super().create(validated_data)


class CandidatureSerializer(serializers.ModelSerializer):
    freelance_nom = serializers.CharField(source='freelance.nom', read_only=True)
    mission_titre = serializers.CharField(source='mission.titre', read_only=True)

    class Meta:
        model = Candidature
        fields = [
            'id', 'mission', 'mission_titre', 'freelance', 'freelance_nom',
            'message', 'prix_propose', 'delai', 'statut', 'date_candidature'
        ]
        read_only_fields = ['id', 'freelance', 'statut', 'date_candidature']

    def create(self, validated_data):
        validated_data['freelance'] = self.context['request'].user
        return super().create(validated_data)


class MessageSerializer(serializers.ModelSerializer):
    sender_nom = serializers.CharField(source='sender.nom', read_only=True)
    receiver_nom = serializers.CharField(source='receiver.nom', read_only=True)

    class Meta:
        model = Message
        fields = ['id', 'sender', 'sender_nom', 'receiver', 'receiver_nom', 'contenu', 'date', 'lu']
        read_only_fields = ['id', 'sender', 'date']

    def create(self, validated_data):
        validated_data['sender'] = self.context['request'].user
        return super().create(validated_data)


class PaiementSerializer(serializers.ModelSerializer):
    mission_titre = serializers.CharField(source='mission.titre', read_only=True)

    class Meta:
        model = Paiement
        fields = ['id', 'mission', 'mission_titre', 'montant', 'statut', 'date']
        read_only_fields = ['id', 'date']


class AvisSerializer(serializers.ModelSerializer):
    auteur_nom = serializers.CharField(source='auteur.nom', read_only=True)

    class Meta:
        model = Avis
        fields = ['id', 'mission', 'auteur', 'auteur_nom', 'note', 'commentaire', 'date']
        read_only_fields = ['id', 'auteur', 'date']

    def create(self, validated_data):
        validated_data['auteur'] = self.context['request'].user
        return super().create(validated_data)
