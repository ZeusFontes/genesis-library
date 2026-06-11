import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class _Notification {
  final String id;
  final String title;
  final String body;
  final String timeLabel;
  final IconData icon;
  final Color iconColor;
  bool read;

  _Notification({
    required this.id,
    required this.title,
    required this.body,
    required this.timeLabel,
    required this.icon,
    required this.iconColor,
    this.read = false,
  });
}

class NotificacoesScreen extends StatefulWidget {
  const NotificacoesScreen({super.key});

  @override
  State<NotificacoesScreen> createState() => _NotificacoesScreenState();
}

class _NotificacoesScreenState extends State<NotificacoesScreen> {
  late List<_Notification> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = [
      _Notification(
        id: 'n1',
        title: 'Novo conteúdo disponível',
        body: 'Metropolis (1927) foi adicionado em alta qualidade ao acervo de domínio público.',
        timeLabel: 'Agora',
        icon: Icons.fiber_new,
        iconColor: AppColors.primaryAccent,
      ),
      _Notification(
        id: 'n2',
        title: 'Atualização do GÊNESIS',
        body: 'Versão 1.2.0 disponível. Melhorias de performance e novos filtros de busca.',
        timeLabel: 'Há 1 hora',
        icon: Icons.system_update_outlined,
        iconColor: Colors.blueAccent,
        read: true,
      ),
      _Notification(
        id: 'n3',
        title: 'Addon ativado',
        body: 'O addon "Modo Cinema" está ativo. Aproveite a experiência imersiva!',
        timeLabel: 'Ontem',
        icon: Icons.extension_outlined,
        iconColor: Colors.purpleAccent,
        read: true,
      ),
      _Notification(
        id: 'n4',
        title: 'Lembrete',
        body: 'Você parou Breaking Bad no episódio 3. Continue de onde parou.',
        timeLabel: 'Há 2 dias',
        icon: Icons.play_circle_outline,
        iconColor: AppColors.softAccent,
        read: true,
      ),
      _Notification(
        id: 'n5',
        title: 'Biblioteca expandida',
        body: '12 novos livros de domínio público foram adicionados esta semana.',
        timeLabel: 'Há 5 dias',
        icon: Icons.menu_book_outlined,
        iconColor: Colors.tealAccent,
        read: true,
      ),
    ];
  }

  int get _unreadCount => _notifications.where((n) => !n.read).length;

  void _markAllRead() {
    setState(() {
      for (final n in _notifications) {
        n.read = true;
      }
    });
  }

  void _markRead(String id) {
    setState(() {
      final idx = _notifications.indexWhere((n) => n.id == id);
      if (idx != -1) _notifications[idx].read = true;
    });
  }

  void _remove(String id) {
    setState(() => _notifications.removeWhere((n) => n.id == id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Notificações'),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$_unreadCount',
                  style: const TextStyle(fontSize: 11, color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Marcar todas', style: TextStyle(color: AppColors.primaryAccent, fontSize: 13)),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? _EmptyNotifications()
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _notifications.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                color: AppColors.secondary,
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (_, i) => _NotificationTile(
                notification: _notifications[i],
                onTap: () => _markRead(_notifications[i].id),
                onDismiss: () => _remove(_notifications[i].id),
              ),
            ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.secondary),
            ),
            child: const Icon(Icons.notifications_none, size: 48, color: AppColors.softAccent),
          ),
          const SizedBox(height: 24),
          const Text('Sem notificações', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            'Você está em dia!\nAvisaremos sobre novidades por aqui.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.grey, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final _Notification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.redAccent.withOpacity(0.15),
        child: const Icon(Icons.delete_outline, color: Colors.redAccent),
      ),
      onDismissed: (_) => onDismiss(),
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: notification.read ? Colors.transparent : AppColors.primaryAccent.withOpacity(0.04),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ícone circular
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: notification.iconColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: notification.iconColor.withOpacity(0.3)),
                ),
                child: Icon(notification.icon, color: notification.iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (!notification.read)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: const TextStyle(color: AppColors.grey, fontSize: 13, height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.timeLabel,
                      style: const TextStyle(color: AppColors.softAccent, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
