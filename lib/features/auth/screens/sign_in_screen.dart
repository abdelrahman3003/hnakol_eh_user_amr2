import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/auth/widgets/sign_in_widget.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class SignInScreen extends StatefulWidget {
  final bool exitFromApp;
  final bool backFromThis;
  const SignInScreen(
      {super.key, required this.exitFromApp, required this.backFromThis});

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _canExit = GetPlatform.isWeb ? true : false;

  @override
  void initState() {
    super.initState();

    _phoneController.text = Get.find<AuthController>().getUserNumber();
    _passwordController.text = Get.find<AuthController>().getUserPassword();
  }

  @override
  Widget build(BuildContext context) {
    // Determine whether the app is in dark mode or not
    bool isDarkMode = Get.isDarkMode;

    return WillPopScope(
      onWillPop: () async {
        if (widget.exitFromApp) {
          if (_canExit) {
            if (GetPlatform.isAndroid) {
              SystemNavigator.pop();
            } else if (GetPlatform.isIOS) {
              exit(0);
            } else {
              Navigator.pushNamed(context, RouteHelper.getInitialRoute());
            }
            return false; // Prevent default pop behavior
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('back_press_again_to_exit'.tr,
                  style: const TextStyle(color: Colors.white)),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            ));
            _canExit = true;
            Timer(const Duration(seconds: 2), () {
              _canExit = false;
            });
            return false; // Prevent default pop behavior
          }
        } else {
          return true; // Allow default pop behavior
        }
      },
      child: Scaffold(
        backgroundColor: ResponsiveHelper.isDesktop(context)
            ? Colors.transparent
            : Theme.of(context).cardColor,
        appBar: ResponsiveHelper.isDesktop(context)
            ? null
            : !widget.exitFromApp
                ? AppBar(
                    leading: IconButton(
                      onPressed: () => Get.back(result: false),
                      icon: Icon(Icons.arrow_back_ios_rounded,
                          color: Theme.of(context).textTheme.bodyLarge!.color),
                    ),
                    elevation: 0,
                    backgroundColor: Theme.of(context).cardColor,
                  )
                : null,
        body: SafeArea(
          child: Center(
            child: Container(
              width: context.width > 700 ? 500 : context.width,
              padding: context.width > 700
                  ? const EdgeInsets.all(50)
                  : const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
              margin: context.width > 700
                  ? const EdgeInsets.all(50)
                  : EdgeInsets.zero,
              decoration: context.width > 700
                  ? BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusSmall),
                      boxShadow: ResponsiveHelper.isDesktop(context)
                          ? null
                          : [
                              BoxShadow(
                                  color:
                                      Colors.grey[Get.isDarkMode ? 700 : 300]!,
                                  blurRadius: 5,
                                  spreadRadius: 1)
                            ],
                    )
                  : null,
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ResponsiveHelper.isDesktop(context)
                          ? Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                onPressed: () => Get.back(),
                                icon: const Icon(Icons.clear),
                              ),
                            )
                          : const SizedBox(),

                      // Display images based on the dark mode setting
                      Image.asset(
                        isDarkMode ? Images.logoDark : Images.logo,
                        width: 150,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      if (!isDarkMode) ...[
                        Image.asset(
                          Images.logoName,
                          width: 120,
                        ),
                      ],
                      const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'sign_in'.tr,
                          style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeExtraLarge),
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      SignInWidget(
                          exitFromApp: widget.exitFromApp,
                          backFromThis: widget.backFromThis),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
