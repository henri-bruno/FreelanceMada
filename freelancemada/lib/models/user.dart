class FreelanceProfile {
  final String competences;
  final String bio;
  final int experience;
  final double noteMoyenne;

  FreelanceProfile({
    required this.competences,
    required this.bio,
    required this.experience,
    required this.noteMoyenne,
  });

  factory FreelanceProfile.fromJson(Map<String, dynamic> json) {
    return FreelanceProfile(
      competences: json['competences'] ?? '',
      bio: json['bio'] ?? '',
      experience: json['experience'] ?? 0,
      noteMoyenne: (json['note_moyenne'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'competences': competences,
    'bio': bio,
    'experience': experience,
  };
}

class User {
  final int id;
  final String nom;
  final String email;
  final String telephone;
  final String? photo;
  final String role;
  final String dateCreation;
  final FreelanceProfile? freelanceProfile;

  User({
    required this.id,
    required this.nom,
    required this.email,
    required this.telephone,
    this.photo,
    required this.role,
    required this.dateCreation,
    this.freelanceProfile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nom: json['nom'] ?? '',
      email: json['email'] ?? '',
      telephone: json['telephone'] ?? '',
      photo: json['photo'],
      role: json['role'] ?? 'client',
      dateCreation: json['date_creation'] ?? '',
      freelanceProfile: json['freelance_profile'] != null
          ? FreelanceProfile.fromJson(json['freelance_profile'])
          : null,
    );
  }

  bool get isClient => role == 'client';
  bool get isFreelance => role == 'freelance';
  bool get isAdmin => role == 'admin';
}
