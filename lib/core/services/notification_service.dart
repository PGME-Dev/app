import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pgme/core/constants/api_constants.dart';
import 'package:pgme/core/models/notification_model.dart';
import 'package:pgme/core/services/api_service.dart';

class NotificationService {
  final ApiService _apiService = ApiService();

  /// Get user notifications
  Future<NotificationResponse> getNotifications({
    int limit = 20,
    int offset = 0,
    String? read,
  }) async {
    try {
      debugPrint('=== Fetching Notifications ===');

      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      if (read != null) {
        queryParams['read'] = read;
      }

      final response = await _apiService.dio.get(
        ApiConstants.notifications,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final notificationsData = data['notifications'] as List;
        final notifications = notificationsData
            .map((json) => NotificationModel.fromJson(json))
            .toList();

        debugPrint('✓ Fetched ${notifications.length} notifications');
        return NotificationResponse(
          notifications: notifications,
          unreadCount: data['unread_count'] as int,
          total: data['total'] as int,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch notifications');
      }
    } on DioException catch (e) {
      debugPrint('Fetch notifications DioException: ${e.response?.data}');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('Fetch notifications error: $e');
      throw Exception('Failed to fetch notifications: ${e.toString()}');
    }
  }

  /// Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      debugPrint('=== Marking Notification as Read ===');
      debugPrint('Notification ID: $notificationId');

      final response = await _apiService.dio.put(
        ApiConstants.markNotificationRead(notificationId),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        debugPrint('✓ Notification marked as read');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to mark notification as read');
      }
    } on DioException catch (e) {
      debugPrint('Mark notification read DioException: ${e.response?.data}');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('Mark notification read error: $e');
      throw Exception('Failed to mark notification as read: ${e.toString()}');
    }
  }

  /// Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      debugPrint('=== Deleting Notification ===');
      debugPrint('Notification ID: $notificationId');

      final response = await _apiService.dio.delete(
        ApiConstants.deleteNotification(notificationId),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        debugPrint('✓ Notification deleted');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to delete notification');
      }
    } on DioException catch (e) {
      debugPrint('Delete notification DioException: ${e.response?.data}');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('Delete notification error: $e');
      throw Exception('Failed to delete notification: ${e.toString()}');
    }
  }
}

class NotificationResponse {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final int total;

  NotificationResponse({
    required this.notifications,
    required this.unreadCount,
    required this.total,
  });
}
