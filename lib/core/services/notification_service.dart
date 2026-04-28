import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/models/admin/notification.dart';
import '../../../main.dart';

class NotificationService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<AdminNotification> _notifications = [];
  bool _isLoading = false;
  RealtimeChannel? _realtimeChannel;

  Function(AdminNotification)? onNotificationClicked;

  List<AdminNotification> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get isLoading => _isLoading;

  void initialize() {
    _listenToRealtimeNotifications();
    fetchNotifications();
  }

  void _listenToRealtimeNotifications() {
    _realtimeChannel = _supabase
        .channel('admin_notifications_channel')
        .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'admin_notifications',
      callback: (payload) {
        print('🔔 New notification received!');
        final newNotification = AdminNotification.fromJson(payload.newRecord);
        _notifications.insert(0, newNotification);
        notifyListeners();
        _showFloatingNotification(newNotification);
      },
    )
        .onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'admin_notifications',
      callback: (payload) {
        final updatedNotification = AdminNotification.fromJson(payload.newRecord);
        final index = _notifications.indexWhere((n) => n.id == updatedNotification.id);
        if (index != -1) {
          _notifications[index] = updatedNotification;
          notifyListeners();
        }
      },
    )
        .subscribe((status, error) {
      if (error != null) {
        print('❌ Realtime subscription error: $error');
      } else {
        print('📡 Realtime subscription status: $status');
      }
    });
  }

  void _showFloatingNotification(AdminNotification notification) {
    print('📢 Showing popup for: ${notification.title}');

    final messenger = rootScaffoldMessengerKey.currentState;
    if (messenger == null) return;

    messenger.removeCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.blue, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    notification.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Text(
                    notification.message,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                messenger.hideCurrentSnackBar();
                if (onNotificationClicked != null) {
                  onNotificationClicked!(notification);
                }
              },
              child: const Text('View'),
            ),
          ],
        ),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(top: 80, right: 20, left: 300),
      ),
    );
  }

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('admin_notifications')
          .select()
          .order('created_at', ascending: false);

      _notifications = response.map((json) => AdminNotification.fromJson(json)).toList();
      print('📋 Fetched ${_notifications.length} notifications');
    } catch (e) {
      print('❌ Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('admin_notifications')
          .update({
        'is_read': true,
        'updated_at': DateTime.now().toIso8601String()
      })
          .eq('id', notificationId);

      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index].isRead = true;
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final unreadIds = _notifications.where((n) => !n.isRead).map((n) => n.id).toList();
      if (unreadIds.isEmpty) return;

      await _supabase
          .from('admin_notifications')
          .update({
        'is_read': true,
        'updated_at': DateTime.now().toIso8601String()
      })
          .inFilter('id', unreadIds);

      for (var notification in _notifications) {
        notification.isRead = true;
      }
      notifyListeners();
    } catch (e) {
      print('❌ Error marking all as read: $e');
    }
  }

  @override
  void dispose() {
    _realtimeChannel?.unsubscribe();
    super.dispose();
  }
}