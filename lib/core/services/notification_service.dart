import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/models/admin/notification.dart';

// Global key for showing snackbars from anywhere
final GlobalKey<ScaffoldMessengerState> globalScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class NotificationService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<AdminNotification> _notifications = [];
  bool _isLoading = false;
  RealtimeChannel? _realtimeChannel;

  // Callback for custom navigation when notification is clicked
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
        print('🔔 NEW NOTIFICATION RECEIVED!');
        final newNotification = AdminNotification.fromJson(payload.newRecord);
        _notifications.insert(0, newNotification);
        notifyListeners();

        // Show popup for new notification
        _showPopupNotification(newNotification);
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
        debugPrint('Realtime subscription error: $error');
      } else {
        debugPrint('Realtime subscription status: $status');
      }
    });
  }

  void _showPopupNotification(AdminNotification notification) {
    final messenger = globalScaffoldMessengerKey.currentState;
    if (messenger == null) return;

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.notifications_active, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    notification.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.message,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(12),
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            if (onNotificationClicked != null) {
              onNotificationClicked!(notification);
            }
          },
        ),
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
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
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
      debugPrint('Error marking notification as read: $e');
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
      debugPrint('Error marking all as read: $e');
    }
  }

  @override
  void dispose() {
    _realtimeChannel?.unsubscribe();
    super.dispose();
  }
}