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
        print('🔔 New notification received!');
        final newNotification = AdminNotification.fromJson(payload.newRecord);
        _notifications.insert(0, newNotification);
        notifyListeners();

        // Show popup
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

    final messenger = globalScaffoldMessengerKey.currentState;
    if (messenger == null) {
      print('❌ Messenger is null, cannot show popup');
      return;
    }

    // Clear any existing snackbars
    messenger.removeCurrentSnackBar();

    // Get screen width
    final screenWidth = messenger.context?.size?.width ?? 400;

    messenger.showSnackBar(
      SnackBar(
        content: GestureDetector(
          onTap: () {
            print('👆 Popup tapped!');
            messenger.hideCurrentSnackBar();
            if (onNotificationClicked != null) {
              onNotificationClicked!(notification);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.notifications_active,
                    color: Colors.blue,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        notification.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        notification.message,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Close button
                GestureDetector(
                  onTap: () {
                    messenger.hideCurrentSnackBar();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        margin: EdgeInsets.only(
          top: 80,  // Position below the header
          right: 20,  // From right edge
          left: screenWidth - 380,  // Width of popup
        ),
        padding: EdgeInsets.zero,
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