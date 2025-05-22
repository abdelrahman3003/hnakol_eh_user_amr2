import 'dart:core';
import 'dart:developer';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:otp_text_field/otp_field.dart';

import '../../../common/widgets/custom_button_widget.dart';
import '../../../common/widgets/custom_text_field_widget.dart';
import '../../../common/widgets/validate_check.dart';
import '../../../helper/responsive_helper.dart';
import '../../../util/dimensions.dart';
import '../../language/controllers/localization_controller.dart';
import '../../splash/controllers/splash_controller.dart';
import '../controllers/auth_controller.dart';


class OTPLoginScreen extends StatefulWidget {
  const OTPLoginScreen({Key? key}) : super(key: key);

  @override
  State<OTPLoginScreen> createState() => _OTPLoginScreenState();
}

class _OTPLoginScreenState extends State<OTPLoginScreen> {

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController numberController = TextEditingController();
  FocusNode _mobileNumberFocus = FocusNode();




  ValueNotifier _valueNotifier = ValueNotifier(true);

  bool isCodeSent = false;




  String otpCode = '';
  String verificationId = '';

  Future<void> sendOTP() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      FocusScope.of(context).requestFocus(FocusNode());

      Fluttertoast.showToast(
        msg: 'sendingOTP',
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.orange,
        textColor: Colors.white
      );

      try {
        print('zeinab');
        isCodeSent = true;
        setState(() {});

        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: "+${_countryDialCode}${numberController.text.trim()}",
          verificationCompleted: (PhoneAuthCredential credential) async {
            print('verificationCompleted failed credintioal $credential');
            Fluttertoast.showToast(
                msg: 'verified',
                toastLength: Toast.LENGTH_SHORT,
                backgroundColor: Colors.orange,
                textColor: Colors.white
            );
            await FirebaseAuth.instance.signInWithCredential(credential);

          },
          verificationFailed: (FirebaseAuthException e) {
            print('verification failed $e');
            if (e.code == 'invalid-phone-number') {
              Fluttertoast.showToast(
                  msg: 'the Entered Code Is Invalid Please TryAgain',
                  toastLength: Toast.LENGTH_SHORT,
                  backgroundColor: Colors.orange,
                  textColor: Colors.white
              );
            } else {
              Fluttertoast.showToast(
                  msg: e.toString(),
                  toastLength: Toast.LENGTH_SHORT,
                  backgroundColor: Colors.orange,
                  textColor: Colors.white
              );
            }
          },
          codeSent: (String _verificationId, int? resendToken) async {
            print('codeSent failed $resendToken');
            print('_verificationId failed $_verificationId');
            Fluttertoast.showToast(
                msg: 'otp Code Is Sent To Your Mobile Number',
                toastLength: Toast.LENGTH_SHORT,
                backgroundColor: Colors.orange,
                textColor: Colors.white
            );

            verificationId = _verificationId;

            if (verificationId.isNotEmpty) {
              isCodeSent = true;
              setState(() {});
            } else {
              //Handle
            }
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            FirebaseAuth.instance.signOut();
            isCodeSent = false;
            setState(() {});
          },
        );

      } on Exception catch (e) {
        print("Error sending OTP: $e");
        log(e.toString());
        Fluttertoast.showToast(
            msg: e.toString(),
            toastLength: Toast.LENGTH_SHORT,
            backgroundColor: Colors.orange,
            textColor: Colors.white
        );
      }
    }
  }

  // Future<void> submitOtp() async {
  //   print('submit  otp');
  //   print(' otp code ====$otpCode');
  //   log(otpCode);
  //   if (otpCode.validate().isNotEmpty) {
  //     if (otpCode.validate().length >= OTP_TEXT_FIELD_LENGTH) {
  //       hideKeyboard(context);
  //       appStore.setLoading(true);
  //       try {
  //         final session = await Supabase.instance.client.auth.verifyOTP(
  //           phone:
  //           "+${selectedCountry.phoneCode}${numberController.text.trim()}",
  //           token: otpCode,
  //           type: OtpType.sms,
  //         );
  //         print("User signed in: ${session.user?.id}");
  //         // PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: otpCode);
  //         // UserCredential credentials = await FirebaseAuth.instance.signInWithCredential(credential);
  //
  //         Map<String, dynamic> request = {
  //           'username': numberController.text.trim(),
  //           'password': numberController.text.trim(),
  //           'login_type': LOGIN_TYPE_OTP,
  //           "uid": session.user?.id.validate(),
  //         };
  //         try {
  //           await loginUser(request, isSocialLogin: true).then((loginResponse) async {
  //             if (loginResponse.isUserExist.validate(value: true)) {
  //               await saveUserData(loginResponse.userData!);
  //               await appStore.setLoginType(LOGIN_TYPE_OTP);
  //               DashboardScreen().launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
  //             } else {
  //               appStore.setLoading(false);
  //               finish(context);
  //               SignUpScreen(
  //                 isOTPLogin: true,
  //                 phoneNumber: numberController.text.trim(),
  //                 countryCode: _countryDialCode.countryCode,
  //                 uid: session.user?.id.validate(),
  //                 // tokenForOTPCredentials: credential.token,
  //               ).launch(context);
  //             }
  //           }).catchError((e) {
  //             finish(context);
  //             appStore.setLoading(false);
  //           });
  //         } catch (e) {
  //           appStore.setLoading(false);
  //         }
  //       }
  //       on Exception catch (e) {
  //         appStore.setLoading(false);
  //         toast(language.theEnteredCodeIsInvalidPleaseTryAgain, print: true);
  //       }
  //     }
  //     else {
  //       toast(language.pleaseEnterValidOTP);
  //     }
  //   } else {
  //     toast(language.pleaseEnterValidOTP);
  //   }
  // }


  //endregion
  String? _countryDialCode;
  @override
  void initState() {
    super.initState();
    _countryDialCode = Get.find<AuthController>().getUserCountryCode().isNotEmpty ? Get.find<AuthController>().getUserCountryCode()
        : CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).dialCode;
  }
  Widget _buildMainWidget() {
    bool isDesktop = ResponsiveHelper.isDesktop(context);


    if (isCodeSent) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            OTPTextField(
              length: 6,
              onChanged: (s) {
                otpCode = s;
                log(otpCode);
              },
              onCompleted: (pin) {
                otpCode = pin;
                //submitOtp();
              },
            ),
            CustomButtonWidget(
              height: isDesktop ? 50 : null,
              width:  isDesktop ? 250 : null,
              buttonText: 'confirm',
              radius: isDesktop ? Dimensions.radiusSmall : Dimensions.radiusDefault,
              isBold: isDesktop ? false : true,
              onPressed:(){
                //submitOtp();
              }
            ),
          ],
        ),
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Form(
            key: formKey,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Country code ...
                // Container(
                //   height: 48.0,
                //   decoration: BoxDecoration(
                //     color:Colors.grey,
                //     borderRadius: BorderRadius.circular(12.0),
                //   ),
                //   child: Center(
                //     child: ValueListenableBuilder(
                //       valueListenable: _valueNotifier,
                //       builder: (context, value, child) => Row(
                //         children: [
                //           Text(
                //             "+20",
                //           ),
                //           Icon(
                //             Icons.arrow_drop_down,
                //             color: Colors.orange,
                //           )
                //         ],
                //       ).paddingOnly(left: 8),
                //     ),
                //   ),
                // ),
                // Mobile number text field...

                SizedBox(
                  width: 300,
                  child: CustomTextFieldWidget(
                    hintText: 'enter_phone_number'.tr,
                    controller: numberController,
                    focusNode: _mobileNumberFocus,
                    inputType: TextInputType.phone,
                    isPhone: true,
                    onCountryChanged: (CountryCode countryCode) {
                      _countryDialCode = countryCode.dialCode;
                    },
                    countryDialCode: _countryDialCode != null ? CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).code
                        : Get.find<LocalizationController>().locale.countryCode,
                    labelText: 'phone'.tr,
                    required: true,
                    validator: (value) => ValidateCheck.validateEmptyText(value, "phone_number_field_is_required".tr),
                    onSubmit:  (s) {
                      //sendOTP();
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 50,),
          CustomButtonWidget(
              height: isDesktop ? 50 : null,
              width:  isDesktop ? 250 : null,
              buttonText: 'send',
              radius: isDesktop ? Dimensions.radiusSmall : Dimensions.radiusDefault,
              isBold: isDesktop ? false : true,
              onPressed:(){
                sendOTP();
              }
          ),
        ],
      );
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(isCodeSent ? 'confirm OTP' : 'EnterPhoneNumber',
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          leading: Navigator.of(context).canPop() ?
          IconButton(
            onPressed:
                    () {
                  Navigator.pop(context);
                },
            icon: Icon(Icons.arrow_back_ios)
          ): null,
          scrolledUnderElevation: 0,
        ),
        body:
        SizedBox(
          // width: MediaQuery.of(context).size.width,
          // height: MediaQuery.of(context).size.height,
          child:  Container(
            padding: const EdgeInsets.all(16),
            child: _buildMainWidget(),
          ),
        )
      ),
    );
  }
}
