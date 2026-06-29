from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.db import models
from django.utils import timezone


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
    prenom = models.CharField(max_length=150, blank=True)
    email = models.EmailField(unique=True)
    telephone = models.CharField(max_length=20, blank=True)
    photo = models.ImageField(upload_to='photos/', blank=True, null=True)
    photo_couverture = models.ImageField(upload_to='couvertures/', blank=True, null=True)
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='client')
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    is_verified = models.BooleanField(default=False)
    is_online = models.BooleanField(default=False)
    derniere_connexion = models.DateTimeField(null=True, blank=True)
    date_creation = models.DateTimeField(auto_now_add=True)
    ville = models.CharField(max_length=100, blank=True)
    pays = models.CharField(max_length=100, blank=True, default='Madagascar')
    langue_interface = models.CharField(max_length=10, default='fr')

    objects = UserManager()

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['nom']

    def __str__(self):
        return f'{self.nom} ({self.role})'

    @property
    def nom_complet(self):
        return f'{self.prenom} {self.nom}'.strip() or self.nom


class FreelanceProfile(models.Model):
    DISPONIBILITE_CHOICES = [
        ('disponible', 'Disponible'),
        ('partiel', 'Partiellement disponible'),
        ('indisponible', 'Indisponible'),
    ]

    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='freelance_profile')
    competences = models.TextField(blank=True)
    bio = models.TextField(blank=True)
    bio_courte = models.CharField(max_length=200, blank=True)
    experience = models.IntegerField(default=0)
    note_moyenne = models.FloatField(default=0.0)
    nb_avis = models.IntegerField(default=0)
    tarif_horaire = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    disponibilite = models.CharField(max_length=20, choices=DISPONIBILITE_CHOICES, default='disponible')
    titre_professionnel = models.CharField(max_length=200, blank=True)
    linkedin = models.URLField(blank=True)
    github = models.URLField(blank=True)
    website = models.URLField(blank=True)
    twitter = models.URLField(blank=True)
    missions_completees = models.IntegerField(default=0)
    taux_reussite = models.FloatField(default=0.0)

    def __str__(self):
        return f'Profil de {self.user.nom}'


class Certification(models.Model):
    freelance = models.ForeignKey(User, on_delete=models.CASCADE, related_name='certifications')
    titre = models.CharField(max_length=200)
    organisme = models.CharField(max_length=200)
    date_obtention = models.DateField()
    date_expiration = models.DateField(null=True, blank=True)
    lien = models.URLField(blank=True)
    fichier = models.FileField(upload_to='certifications/', blank=True, null=True)

    def __str__(self):
        return f'{self.titre} - {self.freelance.nom}'


class Experience(models.Model):
    freelance = models.ForeignKey(User, on_delete=models.CASCADE, related_name='experiences')
    poste = models.CharField(max_length=200)
    entreprise = models.CharField(max_length=200)
    date_debut = models.DateField()
    date_fin = models.DateField(null=True, blank=True)
    en_cours = models.BooleanField(default=False)
    description = models.TextField(blank=True)

    class Meta:
        ordering = ['-date_debut']

    def __str__(self):
        return f'{self.poste} @ {self.entreprise}'


class Portfolio(models.Model):
    freelance = models.ForeignKey(User, on_delete=models.CASCADE, related_name='portfolio')
    titre = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    lien = models.URLField(blank=True)
    image = models.ImageField(upload_to='portfolio/', blank=True, null=True)
    categorie = models.CharField(max_length=100, blank=True)
    date_realisation = models.DateField(null=True, blank=True)
    date_creation = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-date_creation']

    def __str__(self):
        return f'{self.titre} - {self.freelance.nom}'


class PortfolioMedia(models.Model):
    TYPE_CHOICES = [('image', 'Image'), ('video', 'Vidéo'), ('pdf', 'PDF')]
    portfolio = models.ForeignKey(Portfolio, on_delete=models.CASCADE, related_name='medias')
    type = models.CharField(max_length=10, choices=TYPE_CHOICES)
    fichier = models.FileField(upload_to='portfolio/medias/')
    ordre = models.IntegerField(default=0)


class Mission(models.Model):
    STATUT_CHOICES = [
        ('brouillon', 'Brouillon'),
        ('en_attente', 'En attente'),
        ('en_cours', 'En cours'),
        ('termine', 'Terminé'),
        ('annule', 'Annulé'),
    ]
    NIVEAU_CHOICES = [
        ('debutant', 'Débutant'),
        ('intermediaire', 'Intermédiaire'),
        ('expert', 'Expert'),
    ]

    client = models.ForeignKey(User, on_delete=models.CASCADE, related_name='missions_client')
    titre = models.CharField(max_length=200)
    description = models.TextField()
    budget_min = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    budget = models.DecimalField(max_digits=10, decimal_places=2)
    deadline = models.DateField()
    categorie = models.CharField(max_length=100)
    competences_requises = models.TextField(blank=True)
    niveau_experience = models.CharField(max_length=20, choices=NIVEAU_CHOICES, default='intermediaire')
    statut = models.CharField(max_length=20, choices=STATUT_CHOICES, default='en_attente')
    date_creation = models.DateTimeField(auto_now_add=True)
    nb_vues = models.IntegerField(default=0)
    freelance_assigne = models.ForeignKey(
        User, on_delete=models.SET_NULL, null=True, blank=True, related_name='missions_assignees'
    )

    class Meta:
        ordering = ['-date_creation']

    def __str__(self):
        return self.titre


class MissionFichier(models.Model):
    mission = models.ForeignKey(Mission, on_delete=models.CASCADE, related_name='fichiers')
    fichier = models.FileField(upload_to='missions/fichiers/')
    nom_original = models.CharField(max_length=255)
    taille = models.IntegerField(default=0)
    date_upload = models.DateTimeField(auto_now_add=True)


class Service(models.Model):
    freelance = models.ForeignKey(User, on_delete=models.CASCADE, related_name='services')
    titre = models.CharField(max_length=200)
    description = models.TextField()
    categorie = models.CharField(max_length=100)
    image_principale = models.ImageField(upload_to='services/', blank=True, null=True)
    video_presentation = models.URLField(blank=True)
    tags = models.TextField(blank=True)
    actif = models.BooleanField(default=True)
    nb_ventes = models.IntegerField(default=0)
    note_moyenne = models.FloatField(default=0.0)
    date_creation = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-date_creation']

    def __str__(self):
        return f'{self.titre} - {self.freelance.nom}'


class ServicePackage(models.Model):
    NIVEAU_CHOICES = [('basic', 'Basic'), ('standard', 'Standard'), ('premium', 'Premium')]

    service = models.ForeignKey(Service, on_delete=models.CASCADE, related_name='packages')
    niveau = models.CharField(max_length=20, choices=NIVEAU_CHOICES)
    titre = models.CharField(max_length=200)
    description = models.TextField()
    prix = models.DecimalField(max_digits=10, decimal_places=2)
    delai_jours = models.IntegerField()
    nb_revisions = models.IntegerField(default=1)
    fonctionnalites = models.TextField(blank=True)

    class Meta:
        unique_together = ('service', 'niveau')


class ServiceFAQ(models.Model):
    service = models.ForeignKey(Service, on_delete=models.CASCADE, related_name='faqs')
    question = models.CharField(max_length=300)
    reponse = models.TextField()
    ordre = models.IntegerField(default=0)


class ServiceGalerie(models.Model):
    TYPE_CHOICES = [('image', 'Image'), ('video', 'Vidéo')]
    service = models.ForeignKey(Service, on_delete=models.CASCADE, related_name='galerie')
    type = models.CharField(max_length=10, choices=TYPE_CHOICES)
    fichier = models.FileField(upload_to='services/galerie/', blank=True, null=True)
    url = models.URLField(blank=True)
    ordre = models.IntegerField(default=0)


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


class Contrat(models.Model):
    STATUT_CHOICES = [
        ('en_attente', 'En attente signature'),
        ('signe', 'Signé'),
        ('en_cours', 'En cours'),
        ('livre', 'Livré'),
        ('valide', 'Validé'),
        ('annule', 'Annulé'),
        ('litige', 'En litige'),
    ]

    mission = models.OneToOneField(Mission, on_delete=models.CASCADE, related_name='contrat', null=True, blank=True)
    service_package = models.ForeignKey(ServicePackage, on_delete=models.SET_NULL, null=True, blank=True)
    client = models.ForeignKey(User, on_delete=models.CASCADE, related_name='contrats_client')
    freelance = models.ForeignKey(User, on_delete=models.CASCADE, related_name='contrats_freelance')
    titre = models.CharField(max_length=200)
    description = models.TextField()
    montant = models.DecimalField(max_digits=10, decimal_places=2)
    delai_jours = models.IntegerField()
    date_debut = models.DateField(null=True, blank=True)
    date_fin_prevue = models.DateField(null=True, blank=True)
    date_livraison = models.DateTimeField(null=True, blank=True)
    date_validation = models.DateTimeField(null=True, blank=True)
    statut = models.CharField(max_length=20, choices=STATUT_CHOICES, default='en_attente')
    signe_client = models.BooleanField(default=False)
    signe_freelance = models.BooleanField(default=False)
    date_creation = models.DateTimeField(auto_now_add=True)
    conditions = models.TextField(blank=True)
    fichier_pdf = models.FileField(upload_to='contrats/', blank=True, null=True)

    class Meta:
        ordering = ['-date_creation']

    def __str__(self):
        return f'Contrat {self.titre}'


class ContratLivraison(models.Model):
    contrat = models.ForeignKey(Contrat, on_delete=models.CASCADE, related_name='livraisons')
    message = models.TextField()
    date = models.DateTimeField(auto_now_add=True)
    accepte = models.BooleanField(null=True)


class ContratLivraisonFichier(models.Model):
    livraison = models.ForeignKey(ContratLivraison, on_delete=models.CASCADE, related_name='fichiers')
    fichier = models.FileField(upload_to='livraisons/')
    nom_original = models.CharField(max_length=255)


class Message(models.Model):
    TYPE_CHOICES = [
        ('texte', 'Texte'),
        ('image', 'Image'),
        ('video', 'Vidéo'),
        ('audio', 'Audio'),
        ('fichier', 'Fichier'),
    ]

    sender = models.ForeignKey(User, on_delete=models.CASCADE, related_name='messages_envoyes')
    receiver = models.ForeignKey(User, on_delete=models.CASCADE, related_name='messages_recus')
    contenu = models.TextField(blank=True)
    type = models.CharField(max_length=10, choices=TYPE_CHOICES, default='texte')
    fichier = models.FileField(upload_to='messages/fichiers/', blank=True, null=True)
    nom_fichier = models.CharField(max_length=255, blank=True)
    taille_fichier = models.IntegerField(default=0)
    date = models.DateTimeField(auto_now_add=True)
    lu = models.BooleanField(default=False)
    modifie = models.BooleanField(default=False)
    supprime = models.BooleanField(default=False)
    reponse_a = models.ForeignKey('self', on_delete=models.SET_NULL, null=True, blank=True, related_name='reponses')

    class Meta:
        ordering = ['date']

    def __str__(self):
        return f'{self.sender.nom} -> {self.receiver.nom}'


class MessageReaction(models.Model):
    message = models.ForeignKey(Message, on_delete=models.CASCADE, related_name='reactions')
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    emoji = models.CharField(max_length=10)

    class Meta:
        unique_together = ('message', 'user', 'emoji')


class Paiement(models.Model):
    STATUT_CHOICES = [
        ('en_attente', 'En attente'),
        ('paye', 'Payé'),
        ('rembourse', 'Remboursé'),
        ('annule', 'Annulé'),
    ]
    METHODE_CHOICES = [
        ('stripe', 'Stripe'),
        ('paypal', 'PayPal'),
        ('mobile_money', 'Mobile Money'),
        ('virement', 'Virement bancaire'),
        ('portefeuille', 'Portefeuille interne'),
    ]

    contrat = models.ForeignKey(Contrat, on_delete=models.CASCADE, related_name='paiements', null=True, blank=True)
    mission = models.OneToOneField(Mission, on_delete=models.CASCADE, related_name='paiement', null=True, blank=True)
    client = models.ForeignKey(User, on_delete=models.CASCADE, related_name='paiements_client', null=True, blank=True)
    freelance = models.ForeignKey(User, on_delete=models.CASCADE, related_name='paiements_freelance', null=True, blank=True)
    montant = models.DecimalField(max_digits=10, decimal_places=2)
    commission = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    montant_net = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    methode = models.CharField(max_length=20, choices=METHODE_CHOICES, default='portefeuille')
    statut = models.CharField(max_length=20, choices=STATUT_CHOICES, default='en_attente')
    reference = models.CharField(max_length=100, blank=True)
    date = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f'Paiement {self.montant} - {self.statut}'


class Avis(models.Model):
    contrat = models.ForeignKey(Contrat, on_delete=models.SET_NULL, null=True, blank=True, related_name='avis')
    mission = models.ForeignKey(Mission, on_delete=models.CASCADE, related_name='avis', null=True, blank=True)
    service = models.ForeignKey(Service, on_delete=models.CASCADE, related_name='avis', null=True, blank=True)
    auteur = models.ForeignKey(User, on_delete=models.CASCADE, related_name='avis_donnes')
    cible = models.ForeignKey(User, on_delete=models.CASCADE, related_name='avis_recus', null=True, blank=True)
    note = models.IntegerField(choices=[(i, i) for i in range(1, 6)])
    commentaire = models.TextField(blank=True)
    reponse_freelance = models.TextField(blank=True)
    date = models.DateTimeField(auto_now_add=True)
    photos = models.TextField(blank=True)

    def __str__(self):
        return f'Avis {self.note}/5'


class Notification(models.Model):
    TYPE_CHOICES = [
        ('message', 'Nouveau message'),
        ('candidature', 'Nouvelle candidature'),
        ('contrat', 'Contrat'),
        ('paiement', 'Paiement'),
        ('avis', 'Avis'),
        ('mission', 'Mission'),
        ('systeme', 'Système'),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='notifications')
    type = models.CharField(max_length=20, choices=TYPE_CHOICES)
    titre = models.CharField(max_length=200)
    message = models.TextField()
    lien = models.CharField(max_length=200, blank=True)
    lu = models.BooleanField(default=False)
    date = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-date']

    def __str__(self):
        return f'{self.type} - {self.user.nom}'


class Signalement(models.Model):
    TYPE_CHOICES = [
        ('utilisateur', 'Utilisateur'),
        ('mission', 'Mission'),
        ('service', 'Service'),
        ('message', 'Message'),
        ('avis', 'Avis'),
    ]
    STATUT_CHOICES = [
        ('en_attente', 'En attente'),
        ('traite', 'Traité'),
        ('rejete', 'Rejeté'),
    ]

    signaleur = models.ForeignKey(User, on_delete=models.CASCADE, related_name='signalements_envoyes')
    type = models.CharField(max_length=20, choices=TYPE_CHOICES)
    raison = models.TextField()
    statut = models.CharField(max_length=20, choices=STATUT_CHOICES, default='en_attente')
    date = models.DateTimeField(auto_now_add=True)
    objet_id = models.IntegerField(null=True, blank=True)

    def __str__(self):
        return f'Signalement {self.type} par {self.signaleur.nom}'


class Categorie(models.Model):
    nom = models.CharField(max_length=100)
    slug = models.SlugField(unique=True)
    icone = models.CharField(max_length=50, blank=True)
    description = models.TextField(blank=True)
    parent = models.ForeignKey('self', on_delete=models.SET_NULL, null=True, blank=True, related_name='sous_categories')
    actif = models.BooleanField(default=True)
    ordre = models.IntegerField(default=0)

    class Meta:
        ordering = ['ordre', 'nom']

    def __str__(self):
        return self.nom


class Favori(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='favoris')
    freelance = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='mis_en_favori')
    service = models.ForeignKey(Service, on_delete=models.SET_NULL, null=True, blank=True, related_name='favoris')
    date = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = [('user', 'freelance'), ('user', 'service')]
