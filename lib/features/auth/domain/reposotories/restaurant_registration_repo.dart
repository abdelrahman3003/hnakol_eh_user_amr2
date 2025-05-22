import 'package:stackfood_multivendor/api/api_client.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/auth/domain/reposotories/restaurant_registration_repo_interface.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:image_picker/image_picker.dart';

class RestaurantRegistrationRepo implements RestaurantRegistrationRepoInterface {
  final ApiClient apiClient;

  RestaurantRegistrationRepo({required this.apiClient});

  @override
  Future<Response> registerRestaurant(Map<String, String> data, XFile? logo, XFile? cover, List<MultipartDocument> additionalDocument) async {
    return await apiClient.postMultipartData(
      AppConstants.restaurantRegisterUri, data, [MultipartBody('logo', logo), MultipartBody('cover_photo', cover)], additionalDocument,
    );
  }

Future<bool> checkInZone(String? lat, String? lng, int zoneId) async {
  // تأكد من أن الإحداثيات صالحة قبل تنفيذ الطلب
  if (lat != null && lng != null && lat != 0.0 && lng != 0.0) {
    Response response = await apiClient.getData('${AppConstants.checkZoneUri}?lat=$lat&lng=$lng&zone_id=$zoneId');
    
    if (response.statusCode == 200) {
      if (response.body is bool) {
        return response.body as bool;
      } else if (response.body['in_zone'] != null) {
        return response.body['in_zone'] == true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  } else {
    showCustomSnackBar('Invalid location data'); // يمكنك إظهار رسالة للمستخدم
    return false;
  }
}










  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset}) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }
}