
// enum NotificationType{
//   message,
//   order,
//   general,
//   referral_code,
// }
//
// class NotificationBodyModel {
//   NotificationType? notificationType;
//   int? orderId;
//   int? adminId;
//   int? deliverymanId;
//   int? restaurantId;
//   String? type;
//   int? conversationId;
//   int? index;
//   String? image;
//   String? name;
//   String? receiverType;
//
//   NotificationBodyModel({
//     this.notificationType,
//     this.orderId,
//     this.adminId,
//     this.deliverymanId,
//     this.restaurantId,
//     this.type,
//     this.conversationId,
//     this.index,
//     this.image,
//     this.name,
//     this.receiverType,
//   });
//
//   NotificationBodyModel.fromJson(Map<String, dynamic> json) {
//     notificationType = convertToEnum(json['order_notification']);
//     orderId = json['order_id'];
//     adminId = json['admin_id'];
//     deliverymanId = json['deliveryman_id'];
//     restaurantId = json['restaurant_id'];
//     type = json['type'];
//     conversationId = json['conversation_id'];
//     index = json['index'];
//     image = json['image'];
//     name = json['name'];
//     receiverType = json['receiver_type'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['order_notification'] = notificationType.toString();
//     data['order_id'] = orderId;
//     data['admin_id'] = adminId;
//     data['deliveryman_id'] = deliverymanId;
//     data['restaurant_id'] = restaurantId;
//     data['type'] = type;
//     data['conversation_id'] = conversationId;
//     data['index'] = index;
//     data['image'] = image;
//     data['name'] = name;
//     data['receiver_type'] = receiverType;
//     return data;
//   }
//
//   NotificationType convertToEnum(String? enumString) {
//     if(enumString == NotificationType.general.toString()) {
//       return NotificationType.general;
//     }else if(enumString == NotificationType.order.toString()) {
//       return NotificationType.order;
//     }else if(enumString == NotificationType.message.toString()) {
//       return NotificationType.message;
//     } else if(enumString == NotificationType.referral_code.toString()) {
//       return NotificationType.referral_code;
//     }
//     return NotificationType.general;
//   }
//
// }

enum NotificationType{
  message,
  order,
  general,
}

class NotificationBodyModel {
  NotificationType? notificationType;
  int? orderId;
  int? customerId;
  int? conversationId;
  String? type;
    int? adminId;
  int? deliverymanId;
  int? restaurantId;

  NotificationBodyModel({
    this.notificationType,
    this.orderId,
    this.customerId,
    this.deliverymanId,
    this.conversationId,
    this.type,
    this.adminId,
    this.restaurantId
  });

  NotificationBodyModel.fromJson(Map<String, dynamic> json) {
    notificationType = convertToEnum(json['order_notification']);
    orderId = json['order_id'];
    customerId = json['customer_id'];
    deliverymanId = json['delivery_man_id'];
    conversationId = json['conversation_id'];
    type = json['type'];
    adminId = json['admin_id'];
    restaurantId = json['restaurant_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['order_notification'] = notificationType.toString();
    data['order_id'] = orderId;
    data['customer_id'] = customerId;
    data['delivery_man_id'] = deliverymanId;
    data['conversation_id'] = conversationId;
    data['type'] = type;
    data['admin_id'] = adminId;
    data['restaurant_id'] = restaurantId;
    return data;
  }

  NotificationType convertToEnum(String? enumString) {
    if(enumString == NotificationType.general.toString()) {
      return NotificationType.general;
    }else if(enumString == NotificationType.order.toString()) {
      return NotificationType.order;
    }else if(enumString == NotificationType.message.toString()) {
      return NotificationType.message;
    }
    return NotificationType.general;
  }
}