import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/service_provider.dart';
import '../models/service.dart';

class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  final _searchCtrl = TextEditingController();
  String? _categorieSelectionnee;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().loadServices();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _search() {
    context.read<ServiceProvider>().loadServices(
      search: _searchCtrl.text,
      categorie: _categorieSelectionnee,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/services/create'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un service...',
                      prefixIcon: const Icon(Icons.search, color: AppConstants.textMuted),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: AppConstants.textMuted),
                              onPressed: () {
                                _searchCtrl.clear();
                                _search();
                              },
                            )
                          : null,
                    ),
                    onSubmitted: (_) => _search(),
                    onChanged: (v) {
                      if (v.isEmpty) _search();
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),
          // Filtres catégories
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _CatChip(
                  label: 'Tous',
                  selected: _categorieSelectionnee == null,
                  onTap: () {
                    setState(() => _categorieSelectionnee = null);
                    _search();
                  },
                ),
                ...AppConstants.categories.map((cat) => _CatChip(
                  label: cat['nom']!,
                  selected: _categorieSelectionnee == cat['nom'],
                  onTap: () {
                    setState(() => _categorieSelectionnee = cat['nom']);
                    _search();
                  },
                )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Consumer<ServiceProvider>(
              builder: (_, prov, _) {
                if (prov.loading && prov.services.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: AppConstants.goldColor));
                }
                if (prov.services.isEmpty) {
                  return const Center(
                    child: Text('Aucun service trouvé', style: TextStyle(color: AppConstants.textMuted)),
                  );
                }
                return RefreshIndicator(
                  color: AppConstants.goldColor,
                  onRefresh: () => prov.loadServices(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: prov.services.length,
                    itemBuilder: (_, i) => _ServiceCard(
                      service: prov.services[i],
                      onTap: () => context.push('/services/${prov.services[i].id}'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CatChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CatChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppConstants.goldColor : AppConstants.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppConstants.goldColor : AppConstants.borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : AppConstants.textSecondary,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final Service service;
  final VoidCallback onTap;
  const _ServiceCard({required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppConstants.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppConstants.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (service.imagePrincipale != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  service.imagePrincipale!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _NoImage(),
                ),
              )
            else
              _NoImage(),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.titre,
                    style: const TextStyle(
                      color: AppConstants.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppConstants.card2Color,
                        child: Text(
                          service.freelanceNom.isNotEmpty ? service.freelanceNom[0] : '?',
                          style: const TextStyle(color: AppConstants.goldColor, fontSize: 10),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(service.freelanceNom, style: const TextStyle(color: AppConstants.textMuted, fontSize: 12)),
                      const Spacer(),
                      const Icon(Icons.star, size: 14, color: AppConstants.goldColor),
                      const SizedBox(width: 2),
                      Text(
                        service.noteMoyenne.toStringAsFixed(1),
                        style: const TextStyle(color: AppConstants.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppConstants.card2Color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(service.categorie, style: const TextStyle(color: AppConstants.textMuted, fontSize: 11)),
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('À partir de', style: TextStyle(color: AppConstants.textMuted, fontSize: 10)),
                          Text(
                            '${service.prixDepart.toStringAsFixed(0)} Ar',
                            style: const TextStyle(
                              color: AppConstants.goldColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: const BoxDecoration(
        color: AppConstants.card2Color,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: const Center(
        child: Icon(Icons.work_outline, color: AppConstants.textMuted, size: 40),
      ),
    );
  }
}
