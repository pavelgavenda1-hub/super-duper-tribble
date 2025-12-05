import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_service.dart';

// Top-level function for background message handling
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message: ${message.notification?.title}');
}

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  bool _initialized = false;

  // Initialize FCM
  Future<void> init(String userId) async {
    if (_initialized) return;

    // Request permission
    await _requestPermission();

    // Get FCM token
    final token = await _messaging.getToken();
    if (token != null) {
      await _saveFCMToken(userId, token);
    }

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      _saveFCMToken(userId, newToken);
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle notification taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    _initialized = true;
  }

  // Request notification permission
  Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  // Save FCM token to Firestore
  Future<void> _saveFCMToken(String userId, String token) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    print('Foreground message: ${message.notification?.title}');

    final notification = message.notification;
    if (notification != null) {
      _notificationService.showNotification(
        title: notification.title ?? 'World Traveler Stone',
        body: notification.body ?? '',
        payload: message.data['stoneId'],
      );
    }
  }

  // Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.data}');
    // Navigation will be handled by the app
  }

  // Send notification to user about stone being found
  Future<void> sendStoneFoundNotification({
    required String ownerUserId,
    required String finderName,
    required String stoneId,
  }) async {
    try {
      // Get owner's FCM token
      final ownerDoc =
          await _firestore.collection('users').doc(ownerUserId).get();
      final fcmToken = ownerDoc.data()?['fcmToken'] as String?;

      if (fcmToken == null) {
        print('No FCM token for user $ownerUserId');
        return;
      }

      // In production, you would send this via Cloud Functions
      // For now, we'll just log it
      print('Would send notification to $fcmToken: Stone $stoneId found by $finderName');
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  // Send notification to all previous owners
  Future<void> notifyPreviousOwners({
    required List<String> ownerIds,
    required String finderName,
    required String stoneId,
  }) async {
    for (final ownerId in ownerIds) {
      await sendStoneFoundNotification(
        ownerUserId: ownerId,
        finderName: finderName,
        stoneId: stoneId,
      );
    }
  }
}
