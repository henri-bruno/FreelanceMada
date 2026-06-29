class FreelanceProfile {
  final String competences;
  final String bio;
  final String bioCourte;
  final int experience;
  final double noteMoyenne;
  final int nbAvis;
  final double? tarifHoraire;
  final String disponibilite;
  final String titreProfessionnel;
  final String linkedin;
  final String github;
  final String website;
  final int missionsCompletees;
  final double tauxReussite;

  FreelanceProfile({
    required this.competences,
    required this.bio,
    this.bioCourte = '',
    required this.experience,
    required this.noteMoyenne,
    this.nbAvis = 0,
    this.tarifHoraire,
    this.disponibilite = 'disponible',
    this.titreProfessionnel = '',
    this.linkedin = '',
    this.github = '',
    this.website = '',
    this.missionsCompletees = 0,
    this.tauxReussite = 0,
  });

  factory FreelanceProfile.fromJson(Map<String, dynamic> json) {
    return FreelanceProfile(
      competences: json['competences'] ?? '',
      bio: json['bio'] ?? '',
      bioCourte: json['bio_courte'] ?? '',
      experience: json['experience'] ?? 0,
      noteMoyenne: double.tryParse((json['note_moyenne'] ?? 0).toString()) ?? 0,
      nbAvis: json['nb_avis'] ?? 0,
      tarifHoraire: json['tarif_horaire'] != null
          ? double.tryParse(json['tarif_horaire'].toString())
          : null,
      disponibilite: json['disponibilite'] ?? 'disponible',
      titreProfessionnel: json['titre_professionnel'] ?? '',
      linkedin: json['linkedin'] ?? '',
      github: json['github'] ?? '',
      website: json['website'] ?? '',
      missionsCompletees: json['missions_completees'] ?? 0,
      tauxReussite:
          double.tryParse((json['taux_reussite'] ?? 0).toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'competences': competences,
    'bio': bio,
    'bio_courte': bioCourte,
    'experience': experience,
    'tarif_horaire': tarifHoraire,
    'disponibilite': disponibilite,
    'titre_professionnel': titreProfessionnel,
    'linkedin': linkedin,
    'github': github,
    'website': website,
  };
}

class User {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String? photo;
  final String? photoCouverture;
  final String role;
  final bool isVerified;
  final bool isOnline;
  final String ville;
  final String pays;
  final String dateCreation;
  final FreelanceProfile? freelanceProfile;
  final int nbMissions;
  final int nbServices;

  User({
    required this.id,
    required this.nom,
    this.prenom = '',
    required this.email,
    this.telephone = '',
    this.photo,
    this.photoCouverture,
    required this.role,
    this.isVerified = false,
    this.isOnline = false,
    this.ville = '',
    this.pays = 'Madagascar',
    required this.dateCreation,
    this.freelanceProfile,
    this.nbMissions = 0,
    this.nbServices = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      email: json['email'] ?? '',
      telephone: json['telephone'] ?? '',
      photo: json['photo'],
      photoCouverture: json['photo_couverture'],
      role: json['role'] ?? 'client',
      isVerified: json['is_verified'] ?? false,
      isOnline: json['is_online'] ?? false,
      ville: json['ville'] ?? '',
      pays: json['pays'] ?? 'Madagascar',
      dateCreation: json['date_creation'] ?? '',
      freelanceProfile: json['freelance_profile'] != null
          ? FreelanceProfile.fromJson(json['freelance_profile'])
          : null,
      nbMissions: json['nb_missions'] ?? 0,
      nbServices: json['nb_services'] ?? 0,
    );
  }

  String get nomComplet => prenom.isNotEmpty ? '$prenom $nom' : nom;
  bool get isClient => role == 'client';
  bool get isFreelance => role == 'freelance';
  bool get isAdmin => role == 'admin';
}
