import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/no_internet_screen_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/auth/screens/sign_in_screen.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/notification/domain/models/notification_body_model.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/splash/domain/models/deep_link_body.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';

class SplashScreen extends StatefulWidget {
  final bool? exitFromApp;
  final bool? backFromThis;
  final NotificationBodyModel? body;
  final DeepLinkBody? linkBody;
  const SplashScreen(
      {super.key,
      required this.body,
      required this.linkBody,
      this.exitFromApp,
      this.backFromThis});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  late StreamSubscription<ConnectivityResult> _onConnectivityChanged;

  @override
  void initState() {
    super.initState();

    bool firstTime = true;
    _onConnectivityChanged = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (!firstTime) {
        bool isNotConnected = result != ConnectivityResult.wifi &&
            result != ConnectivityResult.mobile;
        isNotConnected
            ? const SizedBox()
            : ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: isNotConnected ? Colors.red : Colors.green,
          duration: Duration(seconds: isNotConnected ? 6000 : 3),
          content: Text(
            isNotConnected ? 'no_connection'.tr : 'connected'.tr,
            textAlign: TextAlign.center,
          ),
        ));
        if (!isNotConnected) {
          _route();
        }
      }
      firstTime = false;
    });

    Get.find<SplashController>().initSharedData();
    if (AddressHelper.getAddressFromSharedPref() != null &&
        (AddressHelper.getAddressFromSharedPref()!.zoneIds == null ||
            AddressHelper.getAddressFromSharedPref()!.zoneData == null)) {
      AddressHelper.clearAddressFromSharedPref();
    }
    if (Get.find<AuthController>().isGuestLoggedIn() ||
        Get.find<AuthController>().isLoggedIn()) {
      Get.find<CartController>().getCartDataOnline();
    }
    _route();
  }

  @override
  void dispose() {
    super.dispose();

    _onConnectivityChanged.cancel();
  }

  void _route() {
    Get.find<SplashController>().getConfigData().then((isSuccess) {
      if (isSuccess) {
        log('----------------- 00');
        Timer(const Duration(seconds: 1), () async {
          double? minimumVersion = 0;
          if (GetPlatform.isAndroid) {
            minimumVersion = Get.find<SplashController>()
                .configModel!
                .appMinimumVersionAndroid;
          } else if (GetPlatform.isIOS) {
            minimumVersion =
                Get.find<SplashController>().configModel!.appMinimumVersionIos;
          }
          if (AppConstants.appVersion < minimumVersion! ||
              Get.find<SplashController>().configModel!.maintenanceMode!) {
            Get.offNamed(RouteHelper.getUpdateRoute(
                AppConstants.appVersion < minimumVersion));
          } else {
            if (widget.body != null && widget.linkBody == null) {
              _forNotificationRouteProcess();
            } else {
              if (Get.find<AuthController>().isLoggedIn()) {
                _forLoggedInUserRouteProcess();
              } else {
                if (Get.find<SplashController>().showIntro()!) {
                  _newlyRegisteredRouteProcess();
                } else {
                  if (Get.find<AuthController>().isGuestLoggedIn()) {
                    _forGuestUserRouteProcess();
                  } else {
                    await Get.find<AuthController>().guestLogin();
                    _forGuestUserRouteProcess();
                    // Get.offNamed(RouteHelper.getSignInRoute(RouteHelper.splash));
                  }
                }
              }
            }
          }
        });
      }
    });
  }

  void _forNotificationRouteProcess() {
    if (widget.body!.notificationType == NotificationType.order) {
      Get.offNamed(RouteHelper.getOrderDetailsRoute(widget.body!.orderId));
    } else if (widget.body!.notificationType == NotificationType.general) {
      Get.offNamed(RouteHelper.getNotificationRoute(fromNotification: true));
    } else {
      Get.offNamed(RouteHelper.getChatRoute(
          notificationBody: widget.body,
          conversationID: widget.body!.conversationId));
    }
  }

  Future<void> _forLoggedInUserRouteProcess() async {
    Get.find<AuthController>().updateToken();
    await Get.find<FavouriteController>().getFavouriteList();
    if (AddressHelper.getAddressFromSharedPref() != null) {
      Get.offNamed(RouteHelper.getInitialRoute(fromSplash: true));
    } else {
      Get.off(const SignInScreen(exitFromApp: true, backFromThis: true));
    }
  }

  void _newlyRegisteredRouteProcess() {
    if (AppConstants.languages.length > 1) {
      Get.offNamed(RouteHelper.getLanguageRoute('splash'));
    } else {
      Get.offNamed(RouteHelper.getOnBoardingRoute());
    }
  }

  void _forGuestUserRouteProcess() {
    if (AddressHelper.getAddressFromSharedPref() != null) {
      Get.offNamed(RouteHelper.getInitialRoute(fromSplash: true));
    } else {
      Get.off(const SignInScreen(exitFromApp: true, backFromThis: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Get.isDarkMode;
    print('Current theme mode: ${isDarkMode ? 'Dark' : 'Light'}');
    return Scaffold(
      //backgroundColor: Colors.black,
      backgroundColor: ResponsiveHelper.isDesktop(context)
          ? Colors.black
          : Theme.of(context).scaffoldBackgroundColor,

      key: _globalKey,
      body: GetBuilder<SplashController>(builder: (splashController) {
        return Center(
          child: splashController.hasConnection
              ? SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isDarkMode) ...[
                        // عرض الصورة الخاصة بالوضع الداكن
                        Padding(
                          padding: const EdgeInsets.only(top: 250),
                          child: Image.asset(
                            Images.logo,
                            width: 300,
                          ),
                        ),
                        //const SizedBox(height: Dimensions.paddingSizeSmall),
                        Image.asset(
                          Images.moneyleekwhite,
                          width: 115,
                        ),
                        const SizedBox(height: 300),
                        Image.asset(
                          Images.moneyleek,
                          width: 40,
                        ),
                      ] else ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 250),
                          child: Image.asset(
                            Images.logo,
                            width: 300,
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        Center(
                          child: Image.asset(
                            Images.logoName,
                            width: 115,
                          ),
                        ),
                        const SizedBox(height: 300),
                        Image.asset(
                          Images.moneyleekdark,
                          width: 40,
                        ),
                      ],
                    ],
                    /*SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                Text(AppConstants.APP_NAME, style: robotoMedium.copyWith(fontSize: 25)),*/
                  ),
                )
              : NoInternetScreen(
                  child: SplashScreen(
                  body: widget.body,
                  linkBody: widget.linkBody,
                )),
        );
      }),
    );
  }
}
