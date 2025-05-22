
import 'package:shared_preferences/shared_preferences.dart';


class SharedPrefs {
  static SharedPreferences? sharedPrefs;

  Future<void> init() async {
    sharedPrefs = await SharedPreferences.getInstance();
  }

  setPhone(String value) {
    sharedPrefs!.setString(phone, value);
  }

  setUserSignupCode(String value) {
    sharedPrefs!.setString(signupCode, value);
  }

  String getSignupCode() {
    return sharedPrefs!.getString(signupCode) ?? '';
  }

  void clear() {
    sharedPrefs!.remove(phone);
  }

  String getPhone() {
    return sharedPrefs!.getString(phone) ?? '';
  }

  String getLanguage() {
    return sharedPrefs!.getString(languageCode) ?? 'ar';
  }

  setLanguage(String value) {
    sharedPrefs!.setString(languageCode, value);
  }
}

///// Object
final sharedPrefs = SharedPrefs();
///// Keys
const String languageCode = 'languageCode';
const String signupCode = 'signupCode';
const String loginResponse = 'loginResponse';
const String phone = 'phone';
