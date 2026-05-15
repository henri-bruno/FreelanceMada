class Mission {
  final int id;
  final int clientId;
  final String clientNom;
  final String titre;
  final String description;
  final double budget;
  final String deadline;
  final String categorie;
  final String statut;
  final String dateCreation;
  final int nbCandidatures;

  Mission({
    required this.id,
    required this.clientId,
    required this.clientNom,
    required this.titre,
    required this.description,
    required this.budget,
    required this.deadline,
    required this.categorie,
    required this.statut,
    required this.dateCreation,
    required this.nbCandidatures,
  });

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: json['id'],
      clientId: json['client'],
      clientNom: json['client_nom'] ?? '',
      titre: json['titre'] ?? '',
      description: json['description'] ?? '',
      budget: (json['budget'] ?? 0).toDouble(),
      deadline: json['deadline'] ?? '',
      categorie: json['categorie'] ?? '',
      statut: json['statut'] ?? 'en_attente',
      dateCreation: json['date_creation'] ?? '',
      nbCandidatures: json['nb_candidatures'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'titre': titre,
    'description': description,
    'budget': budget,
    'deadline': deadline,
    'categorie': categorie,
  };

  String get statutLabel {
    switch (statut) {
      case 'en_attente': return 'En attente';
      case 'en_cours': return 'En cours';
      case 'termine': return 'Terminé';
      case 'annule': return 'Annulé';
      default: return statut;
    }
  }
}
