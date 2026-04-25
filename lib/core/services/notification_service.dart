import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/models/admin/notification.dart';

class NotificationService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<AdminNotification> _notifications = [];
  bool _isLoading = false;
  RealtimeChannel? _realtimeChannel;

  List<AdminNotification> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get isLoading => _isLoading;

  void initialize() {
    _listenToRealtimeNotifications();
    fetchNotifications();
  }

  void _listenToRealtimeNotifications() {
    final adminId = _supabase.auth.currentUser?.id;
    if (adminId == null) return;

    _realtimeChannel = _supabase
        .channel('notifications:admin_id=eq.$adminId')
        .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'notifications',
      callback: (payload) {
        final newNotification = AdminNotification.fromJson(payload.newRecord);
        _notifications.insert(0, newNotification);
        notifyListeners();
      },
    )
        .subscribe();
  }

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final adminId = _supabase.auth.currentUser?.id;
      if (adminId == null) return;

      final response = await _supabase
          .from('notifications')
          .select()
          .eq('admin_id', adminId)
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
          .from('notifications')
          .update({'is_read': true})
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
          .from('notifications')
          .update({'is_read': true})
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