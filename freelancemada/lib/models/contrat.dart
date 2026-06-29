class Contrat {
  final int id;
  final int clientId;
  final int freelanceId;
  final String clientNom;
  final String freelanceNom;
  final String? clientPhoto;
  final String? freelancePhoto;
  final String titre;
  final String description;
  final double montant;
  final int delaiJours;
  final String? dateDebut;
  final String? dateFinPrevue;
  final String? dateLivraison;
  final String? dateValidation;
  final String statut;
  final bool signeClient;
  final bool signeFreelance;
  final String dateCreation;
  final String conditions;

  Contrat({
    required this.id,
    required this.clientId,
    required this.freelanceId,
    required this.clientNom,
    required this.freelanceNom,
    this.clientPhoto,
    this.freelancePhoto,
    required this.titre,
    required this.description,
    required this.montant,
    required this.delaiJours,
    this.dateDebut,
    this.dateFinPrevue,
    this.dateLivraison,
    this.dateValidation,
    required this.statut,
    this.signeClient = false,
    this.signeFreelance = false,
    required this.dateCreation,
    this.conditions = '',
  });

  factory Contrat.fromJson(Map<String, dynamic> json) => Contrat(
    id: json['id'],
    clientId: json['client'] ?? 0,
    freelanceId: json['freelance'] ?? 0,
    clientNom: json['client_nom'] ?? '',
    freelanceNom: json['freelance_nom'] ?? '',
    clientPhoto: json['client_photo'],
    freelancePhoto: json['freelance_photo'],
    titre: json['titre'] ?? '',
    description: json['description'] ?? '',
    montant: double.tryParse((json['montant'] ?? 0).toString()) ?? 0,
    delaiJours: json['delai_jours'] ?? 0,
    dateDebut: json['date_debut'],
    dateFinPrevue: json['date_fin_prevue'],
    dateLivraison: json['date_livraison'],
    dateValidation: json['date_validation'],
    statut: json['statut'] ?? 'en_attente',
    signeClient: json['signe_client'] ?? false,
    signeFreelance: json['signe_freelance'] ?? false,
    dateCreation: json['date_creation'] ?? '',
    conditions: json['conditions'] ?? '',
  );

  String get statutLabel {
    switch (statut) {
      case 'en_attente':
        return 'En attente de signature';
      case 'signe':
        return 'Signé';
      case 'en_cours':
        return 'En cours';
      case 'livre':
        return 'Livré';
      case 'valide':
        return 'Validé';
      case 'annule':
        return 'Annulé';
      case 'litige':
        return 'En litige';
      default:
        return statut;
    }
  }
}
