import 'package:flutter/foundation.dart';
import '../models/app_notification.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  List<AppNotification> _notifications = [];
  bool _isLoading = false;

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // Load notifications from storage
  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final storageService = await StorageService.getInstance();
      _notifications = await storageService.loadAppNotifications();
      _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save notifications to storage
  Future<void> _saveNotifications() async {
    try {
      final storageService = await StorageService.getInstance();
      await storageService.saveAppNotifications(_notifications);
    } catch (e) {
      debugPrint('Error saving notifications: $e');
    }
  }

  // Add a new notification and show it
  Future<void> addNotification(String title, String body) async {
    final newNotification = AppNotification(
      id: DateTime.now().toIso8601String(),
      title: title,
      body: body,
      timestamp: DateTime.now(),
    );
    _notifications.insert(0, newNotification);
    notifyListeners();
    await _saveNotifications();
    await NotificationService().showNotification(title, body);
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    for (var notification in _notifications) {
      notification.isRead = true;
    }
    notifyListeners();
    await _saveNotifications();
  }

  // Delete a notification
  Future<void> deleteNotification(String id) async {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
    await _saveNotifications();
  }
}
