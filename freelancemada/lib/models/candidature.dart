class Candidature {
  final int id;
  final int missionId;
  final String missionTitre;
  final int freelanceId;
  final String freelanceNom;
  final String message;
  final double prixPropose;
  final int delai;
  final String statut;
  final String dateCandidature;

  Candidature({
    required this.id,
    required this.missionId,
    required this.missionTitre,
    required this.freelanceId,
    required this.freelanceNom,
    required this.message,
    required this.prixPropose,
    required this.delai,
    required this.statut,
    required this.dateCandidature,
  });

  factory Candidature.fromJson(Map<String, dynamic> json) {
    return Candidature(
      id: json['id'],
      missionId: json['mission'],
      missionTitre: json['mission_titre'] ?? '',
      freelanceId: json['freelance'],
      freelanceNom: json['freelance_nom'] ?? '',
      message: json['message'] ?? '',
      prixPropose: (json['prix_propose'] ?? 0).toDouble(),
      delai: json['delai'] ?? 0,
      statut: json['statut'] ?? 'en_attente',
      dateCandidature: json['date_candidature'] ?? '',
    );
  }

  String get statutLabel {
    switch (statut) {
      case 'en_attente': return 'En attente';
      case 'accepte': return 'Accepté';
      case 'refuse': return 'Refusé';
      default: return statut;
    }
  }
}
