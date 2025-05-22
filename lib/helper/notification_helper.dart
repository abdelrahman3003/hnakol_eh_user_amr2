import 'dart:convert';
import 'dart:io';
import 'package:stackfood_multivendor/common/widgets/demo_reset_dialog_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/chat/controllers/chat_controller.dart';
import 'package:stackfood_multivendor/features/dashboard/screens/dashboard_screen.dart';
import 'package:stackfood_multivendor/features/notification/controllers/notification_controller.dart';
import 'package:stackfood_multivendor/features/notification/domain/models/notification_body_model.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/common/enums/user_type.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class NotificationHelper {

  static Future<void> initialize(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidInitialize = const AndroidInitializationSettings('notification_icon');
    var iOSInitialize = const DarwinInitializationSettings();
    var initializationsSettings = InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()!.requestNotificationsPermission();
    flutterLocalNotificationsPlugin.initialize(initializationsSettings, onDidReceiveNotificationResponse: (NotificationResponse response) async {
      try{
        NotificationBodyModel payload;
        if(response.payload!.isNotEmpty) {
          payload = NotificationBodyModel.fromJson(jsonDecode(response.payload!));
          if(payload.notificationType == NotificationType.order) {
            if(Get.find<AuthController>().isGuestLoggedIn()){
              Get.to(()=> const DashboardScreen(pageIndex: 3, fromSplash: false));
            } else {
              Get.toNamed(RouteHelper.getOrderDetailsRoute(int.parse(payload.orderId.toString())));
            }
          } else if(payload.notificationType == NotificationType.general) {
            Get.toNamed(RouteHelper.getNotificationRoute(fromNotification: true));
          } else{
            Get.toNamed(RouteHelper.getChatRoute(notificationBody: payload, conversationID: payload.conversationId));
          }
        }
      }catch (_) {}
      return;
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("onMessage: ${message.notification?.title}/${message.notification?.body}/${message.data}");

      if(message.notification?.title == 'demo_reset') {
        Get.dialog(const DemoResetDialogWidget(), barrierDismissible: false);
      }
      if(message.data['type'] == 'message' && Get.currentRoute.startsWith(RouteHelper.messages)) {
        if(Get.find<AuthController>().isLoggedIn()) {
          Get.find<ChatController>().getConversationList(1, fromTab: false);
          if(Get.find<ChatController>().messageModel!.conversation!.id.toString() == message.data['conversation_id'].toString()) {
            Get.find<ChatController>().getMessages(
              1, NotificationBodyModel(
                notificationType: NotificationType.message, adminId: message.data['sender_type'] == UserType.admin.name ? 0 : null,
                restaurantId: message.data['sender_type'] == UserType.vendor.name ? 0 : null,
                deliverymanId: message.data['sender_type'] == UserType.delivery_man.name ? 0 : null,
              ),
              null, int.parse(message.data['conversation_id'].toString()),
            );
          }else {
          NotificationHelper.showNotification(
            flutterLocalNotificationsPlugin,
            message.notification?.title ?? '',
            message.notification?.body ?? '',
            message.data,
          );
          }
        }
      }else if(message.data['type'] == 'message' && Get.currentRoute.startsWith(RouteHelper.conversation)) {
        if(Get.find<AuthController>().isLoggedIn()) {
          Get.find<ChatController>().getConversationList(1, fromTab: false);
        }
        NotificationHelper.showNotification(
          flutterLocalNotificationsPlugin,
          message.notification?.title ?? '',
          message.notification?.body ?? '',
          message.data,
        );
      }
      /*else if(message.data['type'] == 'referral_code') {
        NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin, false);
      } */
      else {

        NotificationHelper.showNotification(
          flutterLocalNotificationsPlugin,
          message.notification?.title ?? '',
          message.notification?.body ?? '',
          message.data,
        );
        if(Get.find<AuthController>().isLoggedIn()) {
          Get.find<OrderController>().getRunningOrders(1);
          Get.find<OrderController>().getHistoryOrders(1);
          Get.find<NotificationController>().getNotificationList(true);
        }
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("onOpenApp: ${message.notification!.title}/${message.notification!.body}/${message.notification!.titleLocKey}");
      try{
        if(message.data.isNotEmpty) {
          NotificationBodyModel notificationBody = convertNotification(message.data);
          if(notificationBody.notificationType == NotificationType.order) {
            Get.toNamed(RouteHelper.getOrderDetailsRoute(int.parse(message.data['order_id'])));
          } else if(notificationBody.notificationType == NotificationType.general) {
            Get.toNamed(RouteHelper.getNotificationRoute(fromNotification: true));
          } else{
            Get.toNamed(RouteHelper.getChatRoute(notificationBody: notificationBody, conversationID: notificationBody.conversationId));
          }
        }
      }catch (_) {}
    });
  }

  static Future<void> showNotification(
      FlutterLocalNotificationsPlugin fln,
      String title,
      String body,
      Map<String, dynamic> data,
      ) async {
    if (!GetPlatform.isIOS) {
      String? image;
      NotificationBodyModel notificationBody = convertNotification(data);

      if (GetPlatform.isAndroid) {
        image = (data['android_image'] != null && data['android_image'].isNotEmpty)
            ? data['android_image'].startsWith('http') ? data['android_image']
            : '${AppConstants.baseUrl}/storage/app/public/notification/${data['android_image']}' : null;
      } else if (GetPlatform.isIOS) {
        image = (data['ios_image'] != null && data['ios_image'].isNotEmpty)
            ? data['ios_image'].startsWith('http') ? data['ios_image']
            : '${AppConstants.baseUrl}/storage/app/public/notification/${data['ios_image']}' : null;
      }

      if (image != null && image.isNotEmpty) {
        try {
          await showBigPictureNotificationHiddenLargeIcon(title, body, notificationBody, image, fln);
        } catch (e) {
          await showBigTextNotification(title, body, notificationBody, fln);
        }
      } else {
        await showBigTextNotification(title, body, notificationBody, fln);
      }
    }
  }

  static Future<void> showTextNotification(String title, String body, NotificationBodyModel? notificationBody, FlutterLocalNotificationsPlugin fln) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'stackfood', 'stackfood', playSound: true,
      importance: Importance.max, priority: Priority.max, sound: RawResourceAndroidNotificationSound('notification'),
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, title, body, platformChannelSpecifics, payload: notificationBody != null ? jsonEncode(notificationBody.toJson()) : null);
  }

  static Future<void> showBigTextNotification(String? title, String body, NotificationBodyModel? notificationBody, FlutterLocalNotificationsPlugin fln) async {
    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      body, htmlFormatBigText: true,
      contentTitle: title, htmlFormatContentTitle: true,
    );
    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'stackfood', 'stackfood', importance: Importance.max,
      styleInformation: bigTextStyleInformation, priority: Priority.max, playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification'),
    );
    NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, title, body, platformChannelSpecifics, payload: notificationBody != null ? jsonEncode(notificationBody.toJson()) : null);
  }




  static Future<void> showBigPictureNotificationHiddenLargeIcon(String? title, String? body, NotificationBodyModel? notificationBody, String image, FlutterLocalNotificationsPlugin fln) async {
    final String largeIconPath = await _downloadAndSaveFile(image, 'largeIcon');
    final String bigPicturePath = await _downloadAndSaveFile(image, 'bigPicture');
    final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath), hideExpandedLargeIcon: true,
      contentTitle: title, htmlFormatContentTitle: true,
      summaryText: body, htmlFormatSummaryText: true,
    );
    final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'stackfood', 'stackfood',
      largeIcon: FilePathAndroidBitmap(largeIconPath), priority: Priority.max, playSound: true,
      styleInformation: bigPictureStyleInformation, importance: Importance.max,
      sound: const RawResourceAndroidNotificationSound('notification'),
    );
    final NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, title, body, platformChannelSpecifics, payload: notificationBody != null ? jsonEncode(notificationBody.toJson()) : null);
  }

  static Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/$fileName';
    final response = await http.get(Uri.parse(url));
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  static NotificationBodyModel convertNotification(Map<String, dynamic> data) {
    return NotificationBodyModel.fromJson(data);
  }


}

Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  debugPrint("onBackground: ${message.notification!.title}/${message.notification!.body}/${message.notification!.titleLocKey}");
  // var androidInitialize = new AndroidInitializationSettings('notification_icon');
  // var iOSInitialize = new DarwinInitializationSettings();
  // var initializationsSettings = new InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
  // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  // flutterLocalNotificationsPlugin.initialize(initializationsSettings);
  // NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin, false);
}