class Mission {
  final int id;
  final int clientId;
  final String clientNom;
  final String? clientPhoto;
  final int? freelanceAssigneId;
  final String? freelanceNom;
  final String titre;
  final String description;
  final double budgetMin;
  final double budget;
  final String deadline;
  final String categorie;
  final String competencesRequises;
  final String niveauExperience;
  final String statut;
  final int nbVues;
  final String dateCreation;
  final int nbCandidatures;

  Mission({
    required this.id,
    required this.clientId,
    required this.clientNom,
    this.clientPhoto,
    this.freelanceAssigneId,
    this.freelanceNom,
    required this.titre,
    required this.description,
    this.budgetMin = 0,
    required this.budget,
    required this.deadline,
    required this.categorie,
    this.competencesRequises = '',
    this.niveauExperience = 'intermediaire',
    required this.statut,
    this.nbVues = 0,
    required this.dateCreation,
    this.nbCandidatures = 0,
  });

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: json['id'],
      clientId: json['client'] ?? 0,
      clientNom: json['client_nom'] ?? '',
      clientPhoto: json['client_photo'],
      freelanceAssigneId: json['freelance_assigne'],
      freelanceNom: json['freelance_nom'],
      titre: json['titre'] ?? '',
      description: json['description'] ?? '',
      budgetMin: double.tryParse((json['budget_min'] ?? 0).toString()) ?? 0,
      budget: double.tryParse((json['budget'] ?? 0).toString()) ?? 0,
      deadline: json['deadline'] ?? '',
      categorie: json['categorie'] ?? '',
      competencesRequises: json['competences_requises'] ?? '',
      niveauExperience: json['niveau_experience'] ?? 'intermediaire',
      statut: json['statut'] ?? 'en_attente',
      nbVues: json['nb_vues'] ?? 0,
      dateCreation: json['date_creation'] ?? '',
      nbCandidatures: json['nb_candidatures'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'titre': titre,
    'description': description,
    'budget_min': budgetMin,
    'budget': budget,
    'deadline': deadline,
    'categorie': categorie,
    'competences_requises': competencesRequises,
    'niveau_experience': niveauExperience,
  };

  String get statutLabel {
    switch (statut) {
      case 'brouillon':
        return 'Brouillon';
      case 'en_attente':
        return 'En attente';
      case 'en_cours':
        return 'En cours';
      case 'termine':
        return 'Terminé';
      case 'annule':
        return 'Annulé';
      default:
        return statut;
    }
  }

  String get niveauLabel {
    switch (niveauExperience) {
      case 'debutant':
        return 'Débutant';
      case 'intermediaire':
        return 'Intermédiaire';
      case 'expert':
        return 'Expert';
      default:
        return niveauExperience;
    }
  }
}
