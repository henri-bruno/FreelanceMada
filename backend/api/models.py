from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.db import models


class UserManager(BaseUserManager):
    def create_user(self, email, nom, password=None, **extra_fields):
        if not email:
            raise ValueError('Email obligatoire')
        email = self.normalize_email(email)
        user = self.model(email=email, nom=nom, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, nom, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('role', 'admin')
        return self.create_user(email, nom, password, **extra_fields)


class User(AbstractBaseUser, PermissionsMixin):
    ROLE_CHOICES = [
        ('client', 'Client'),
        ('freelance', 'Freelance'),
        ('admin', 'Admin'),
    ]

    nom = models.CharField(max_length=150)
    email = models.EmailField(unique=True)
    telephone = models.CharField(max_length=20, blank=True)
    photo = models.ImageField(upload_to='photos/', blank=True, null=True)
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='client')
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    date_creation = models.DateTimeField(auto_now_add=True)

    objects = UserManager()

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['nom']

    def __str__(self):
        return f'{self.nom} ({self.role})'


class FreelanceProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='freelance_profile')
    competences = models.TextField(blank=True)
    bio = models.TextField(blank=True)
    experience = models.IntegerField(default=0)
    note_moyenne = models.FloatField(default=0.0)

    def __str__(self):
        return f'Profil de {self.user.nom}'


class Mission(models.Model):
    STATUT_CHOICES = [
        ('en_attente', 'En attente'),
        ('en_cours', 'En cours'),
        ('termine', 'Terminé'),
        ('annule', 'Annulé'),
    ]

    client = models.ForeignKey(User, on_delete=models.CASCADE, related_name='missions_client')
    titre = models.CharField(max_length=200)
    description = models.TextField()
    budget = models.DecimalField(max_digits=10, decimal_places=2)
    deadline = models.DateField()
    categorie = models.CharField(max_length=100)
    statut = models.CharField(max_length=20, choices=STATUT_CHOICES, default='en_attente')
    date_creation = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-date_creation']

    def __str__(self):
        return self.titre


class Candidature(models.Model):
    STATUT_CHOICES = [
        ('en_attente', 'En attente'),
        ('accepte', 'Accepté'),
        ('refuse', 'Refusé'),
    ]

    mission = models.ForeignKey(Mission, on_delete=models.CASCADE, related_name='candidatures')
    freelance = models.ForeignKey(User, on_delete=models.CASCADE, related_name='candidatures')
    message = models.TextField()
    prix_propose = models.DecimalField(max_digits=10, decimal_places=2)
    delai = models.IntegerField(help_text='Délai en jours')
    statut = models.CharField(max_length=20, choices=STATUT_CHOICES, default='en_attente')
    date_candidature = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('mission', 'freelance')

    def __str__(self):
        return f'{self.freelance.nom} -> {self.mission.titre}'


class Message(models.Model):
    sender = models.ForeignKey(User, on_delete=models.CASCADE, related_name='messages_envoyes')
    receiver = models.ForeignKey(User, on_delete=models.CASCADE, related_name='messages_recus')
    contenu = models.TextField()
    date = models.DateTimeField(auto_now_add=True)
    lu = models.BooleanField(default=False)

    class Meta:
        ordering = ['date']

    def __str__(self):
        return f'{self.sender.nom} -> {self.receiver.nom}'


class Paiement(models.Model):
    STATUT_CHOICES = [
        ('en_attente', 'En attente'),
        ('paye', 'Payé'),
        ('rembourse', 'Remboursé'),
    ]

    mission = models.OneToOneField(Mission, on_delete=models.CASCADE, related_name='paiement')
    montant = models.DecimalField(max_digits=10, decimal_places=2)
    statut = models.CharField(max_length=20, choices=STATUT_CHOICES, default='en_attente')
    date = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f'Paiement {self.mission.titre} - {self.statut}'


class Avis(models.Model):
    mission = models.ForeignKey(Mission, on_delete=models.CASCADE, related_name='avis')
    auteur = models.ForeignKey(User, on_delete=models.CASCADE, related_name='avis_donnes')
    note = models.IntegerField(choices=[(i, i) for i in range(1, 6)])
    commentaire = models.TextField(blank=True)
    date = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f'Avis {self.note}/5 sur {self.mission.titre}'
