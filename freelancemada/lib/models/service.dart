class ServicePackage {
  final int id;
  final int serviceId;
  final String niveau;
  final String titre;
  final String description;
  final double prix;
  final int delaiJours;
  final int nbRevisions;
  final String fonctionnalites;

  ServicePackage({
    required this.id,
    required this.serviceId,
    required this.niveau,
    required this.titre,
    required this.description,
    required this.prix,
    required this.delaiJours,
    this.nbRevisions = 1,
    this.fonctionnalites = '',
  });

  factory ServicePackage.fromJson(Map<String, dynamic> json) => ServicePackage(
    id: json['id'],
    serviceId: json['service'],
    niveau: json['niveau'] ?? 'basic',
    titre: json['titre'] ?? '',
    description: json['description'] ?? '',
    prix: double.tryParse((json['prix'] ?? 0).toString()) ?? 0,
    delaiJours: json['delai_jours'] ?? 1,
    nbRevisions: json['nb_revisions'] ?? 1,
    fonctionnalites: json['fonctionnalites'] ?? '',
  );

  String get niveauLabel {
    switch (niveau) {
      case 'basic':
        return 'Basic';
      case 'standard':
        return 'Standard';
      case 'premium':
        return 'Premium';
      default:
        return niveau;
    }
  }
}

class Service {
  final int id;
  final int freelanceId;
  final String freelanceNom;
  final String? freelancePhoto;
  final double freelanceNote;
  final String titre;
  final String description;
  final String categorie;
  final String? imagePrincipale;
  final String tags;
  final bool actif;
  final int nbVentes;
  final double noteMoyenne;
  final String dateCreation;
  final List<ServicePackage> packages;

  Service({
    required this.id,
    required this.freelanceId,
    required this.freelanceNom,
    this.freelancePhoto,
    this.freelanceNote = 0,
    required this.titre,
    required this.description,
    required this.categorie,
    this.imagePrincipale,
    this.tags = '',
    this.actif = true,
    this.nbVentes = 0,
    this.noteMoyenne = 0,
    required this.dateCreation,
    this.packages = const [],
  });

  factory Service.fromJson(Map<String, dynamic> json) => Service(
    id: json['id'],
    freelanceId: json['freelance'] ?? 0,
    freelanceNom: json['freelance_nom'] ?? '',
    freelancePhoto: json['freelance_photo'],
    freelanceNote:
        double.tryParse((json['freelance_note'] ?? 0).toString()) ?? 0,
    titre: json['titre'] ?? '',
    description: json['description'] ?? '',
    categorie: json['categorie'] ?? '',
    imagePrincipale: json['image_principale'],
    tags: json['tags'] ?? '',
    actif: json['actif'] ?? true,
    nbVentes: json['nb_ventes'] ?? 0,
    noteMoyenne: double.tryParse((json['note_moyenne'] ?? 0).toString()) ?? 0,
    dateCreation: json['date_creation'] ?? '',
    packages: (json['packages'] as List<dynamic>? ?? [])
        .map((p) => ServicePackage.fromJson(p))
        .toList(),
  );

  double get prixDepart {
    if (packages.isEmpty) return 0;
    return packages.map((p) => p.prix).reduce((a, b) => a < b ? a : b);
  }

  List<String> get tagsList =>
      tags.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
}
