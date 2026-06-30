import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/notification_provider.dart';
import '../models/notification.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().load();
    });
  }

  IconData _icon(String type) {
    switch (type) {
      case 'message': return Icons.chat_bubble_outline;
      case 'candidature': return Icons.person_add_outlined;
      case 'contrat': return Icons.description_outlined;
      case 'paiement': return Icons.payment;
      case 'avis': return Icons.star_outline;
      case 'mission': return Icons.work_outline;
      default: return Icons.notifications_outlined;
    }
  }

  Color _color(String type) {
    switch (type) {
      case 'message': return AppConstants.infoColor;
      case 'paiement': return AppConstants.successColor;
      case 'avis': return AppConstants.goldColor;
      case 'contrat': return AppConstants.warningColor;
      default: return AppConstants.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (_, prov, child) => prov.unreadCount > 0
                ? TextButton(
                    onPressed: () => prov.markRead(null),
                    child: const Text('Tout lire'),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (_, prov, child) {
          if (prov.loading) {
            return const Center(child: CircularProgressIndicator(color: AppConstants.goldColor));
          }
          if (prov.notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64, color: AppConstants.textMuted),
                  SizedBox(height: 16),
                  Text('Aucune notification', style: TextStyle(color: AppConstants.textMuted, fontSize: 16)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            color: AppConstants.goldColor,
            onRefresh: prov.load,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: prov.notifications.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final n = prov.notifications[i];
                return _NotifCard(
                  notification: n,
                  icon: _icon(n.type),
                  color: _color(n.type),
                  onTap: () => prov.markRead(n.id),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final AppNotification notification;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _NotifCard({
    required this.notification,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final n = notification;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: n.lu ? AppConstants.cardColor : AppConstants.card2Color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: n.lu ? AppConstants.borderColor : color.withAlpha(80),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          n.titre,
                          style: TextStyle(
                            color: AppConstants.textPrimary,
                            fontWeight: n.lu ? FontWeight.w500 : FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (!n.lu)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n.message,
                    style: const TextStyle(color: AppConstants.textSecondary, fontSize: 13, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatDate(n.date),
                    style: const TextStyle(color: AppConstants.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String date) {
    if (date.isEmpty) return '';
    try {
      final dt = DateTime.parse(date).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'À l\'instant';
      if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
      if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
      return 'Il y a ${diff.inDays}j';
    } catch (_) {
      return date;
    }
  }
}
