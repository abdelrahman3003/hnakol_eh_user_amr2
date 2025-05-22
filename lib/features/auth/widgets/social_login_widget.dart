import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/auth/domain/models/social_log_in_body_model.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SocialLoginWidget extends StatefulWidget {
  const SocialLoginWidget({super.key});

  @override
  State<SocialLoginWidget> createState() => _SocialLoginWidgetState();
}

class _SocialLoginWidgetState extends State<SocialLoginWidget> {
  late WebViewController _controller;
  final storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    // final GoogleSignIn googleSignIn = GoogleSignIn();
    return Get.find<SplashController>().configModel!.socialLogin!.isNotEmpty &&
            (Get.find<SplashController>()
                    .configModel!
                    .socialLogin![0]
                    .status! ||
                Get.find<SplashController>()
                    .configModel!
                    .socialLogin![1]
                    .status!)
        ? Column(children: [
            Center(child: Text('social_login'.tr, style: robotoMedium)),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Get.find<SplashController>().configModel!.socialLogin![0].status!
                  ? InkWell(
                      onTap: () async {
                        try {
                          final GoogleSignIn googleSignIn = GoogleSignIn(
                            clientId:
                                "303325207155-ht1jen4bus2q7lfftbeh5qf7lrrcpkpl.apps.googleusercontent.com",
                            scopes: ['email', 'profile'],
                          );
                          final GoogleSignInAccount? googleUser =
                              await googleSignIn.signIn();
                          if (googleUser == null) return;
                          final GoogleSignInAuthentication googleAuth =
                              await googleUser.authentication;
                          print('accessToken: ${googleAuth.accessToken}');
                          final String? idToken = googleAuth.idToken;
                          log('-------------------------idToken: ${googleAuth.idToken}');

                          if (idToken != null) {
                            Get.find<AuthController>()
                                .loginWithSocialMedia(SocialLogInBodyModel(
                              email: googleUser.email,
                              token: googleAuth.idToken,
                              uniqueId: googleUser.id,
                              medium: 'google',
                            ));
                          }
                        } catch (e) {
                          log("Error during Google Sign-In: $e");
                          return;
                        }
                        // signInWithGoogle();
                        // const webClientId =
                        //     '95428465585-nshtekq8sv0dn349hr0s26k57qooperv.apps.googleusercontent.com';
                        // const iosClientId =
                        //     '95428465585-6aictb0sb9jc6eenfbuma3gd85nd7ntq.apps.googleusercontent.com';
                        //
                        // try{
                        //   final GoogleSignIn googleSignIn = GoogleSignIn(
                        //     clientId: iosClientId,
                        //     serverClientId: webClientId,
                        //   );
                        //   final googleUser = await googleSignIn.signIn();
                        //   final googleAuth = await googleUser!.authentication;
                        //   final accessToken = googleAuth.accessToken;
                        //   final idToken = googleAuth.idToken;
                        //   if (accessToken == null) {
                        //     print('No Access Token found.');
                        //     throw 'No Access Token found.';
                        //   }
                        //   if (idToken == null) {
                        //     print('No ID Token found..');
                        //     throw 'No ID Token found.';
                        //   }
                        //   await supabase.auth.signInWithIdToken(
                        //     provider: OAuthProvider.google,
                        //     idToken: idToken,
                        //     accessToken: accessToken,
                        //   );
                        //   Get.find<AuthController>()
                        //       .loginWithSocialMedia(SocialLogInBodyModel(
                        //     email: googleUser.email,
                        //     token: idToken,
                        //     uniqueId: googleUser.id,
                        //     medium: 'google',
                        //   ));
                        // }catch(e){
                        //   print('errrrrorr==$e');
                        // }
                        // googleSignIn.signOut();
                        // GoogleSignInAccount googleAccount = (await googleSignIn.signIn())!;
                        // GoogleSignInAuthentication auth = await googleAccount.authentication;
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        padding: const EdgeInsets.all(
                            Dimensions.paddingSizeExtraSmall),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey[Get.isDarkMode ? 700 : 300]!,
                                spreadRadius: 1,
                                blurRadius: 5)
                          ],
                        ),
                        child: Image.asset(Images.google),
                      ),
                    )
                  : const SizedBox(),
              // SizedBox(width: Get.find<SplashController>().configModel!.socialLogin![0].status! ? Dimensions.paddingSizeLarge : 0),

              Get.find<SplashController>().configModel!.socialLogin![1].status!
                  ? Padding(
                      padding: EdgeInsets.only(
                          left: Get.find<LocalizationController>().isLtr
                              ? Dimensions.paddingSizeLarge
                              : 0,
                          right: Get.find<LocalizationController>().isLtr
                              ? 0
                              : Dimensions.paddingSizeLarge),
                      child: InkWell(
                        onTap: () async {
                          LoginResult result = await FacebookAuth.instance
                              .login(permissions: ["email", "public_profile"]);
                          if (result.status == LoginStatus.success) {
                            //final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.token);
                            print(
                                'accessToken == ${result.accessToken!.tokenString}');
                            Map userData =
                                await FacebookAuth.instance.getUserData();
                            Get.find<AuthController>()
                                .loginWithSocialMedia(SocialLogInBodyModel(
                              email: userData['email'],
                              token: result.accessToken!.tokenString,
                              uniqueId: 'me',
                              medium: 'facebook',
                            ));
                          }
                        },
                        child: Container(
                          height: 40,
                          width: 40,
                          padding: const EdgeInsets.all(
                              Dimensions.paddingSizeExtraSmall),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5)),
                            boxShadow: [
                              BoxShadow(
                                  color:
                                      Colors.grey[Get.isDarkMode ? 700 : 300]!,
                                  spreadRadius: 1,
                                  blurRadius: 5)
                            ],
                          ),
                          child: Image.asset(Images.facebookIcon),
                        ),
                      ),
                    )
                  : const SizedBox(),
              // const SizedBox(width: Dimensions.paddingSizeLarge),

              Get.find<SplashController>()
                          .configModel!
                          .appleLogin!
                          .isNotEmpty &&
                      Get.find<SplashController>()
                          .configModel!
                          .appleLogin![0]
                          .status! &&
                      !GetPlatform.isAndroid &&
                      !GetPlatform.isWeb
                  ? Padding(
                      padding: const EdgeInsets.only(
                          left: Dimensions.paddingSizeLarge),
                      child: InkWell(
                        onTap: () async {
                          final credential =
                              await SignInWithApple.getAppleIDCredential(
                            scopes: [
                              AppleIDAuthorizationScopes.email,
                              AppleIDAuthorizationScopes.fullName,
                            ],
                            webAuthenticationOptions: WebAuthenticationOptions(
                              clientId: Get.find<SplashController>()
                                  .configModel!
                                  .appleLogin![0]
                                  .clientId!,
                              redirectUri: Uri.parse(
                                  'https://hanakoleah.site/customer/auth/login/apple/callback'),
                            ),
                          );
                          Get.find<AuthController>()
                              .loginWithSocialMedia(SocialLogInBodyModel(
                            email: credential.email,
                            token: credential.authorizationCode,
                            uniqueId: credential.authorizationCode,
                            medium: 'apple',
                          ));
                        },
                        child: Container(
                          height: 40,
                          width: 40,
                          padding: const EdgeInsets.all(
                              Dimensions.paddingSizeExtraSmall),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5)),
                            boxShadow: [
                              BoxShadow(
                                  color:
                                      Colors.grey[Get.isDarkMode ? 700 : 300]!,
                                  spreadRadius: 1,
                                  blurRadius: 5)
                            ],
                          ),
                          child: Image.asset(Images.appleLogo),
                        ),
                      ),
                    )
                  : const SizedBox(),
            ]),
            const SizedBox(height: Dimensions.paddingSizeSmall),
          ])
        : const SizedBox();
  }

  // redirect google url
  Future<void> signInWithGoogle() async {
    print('signInWithGoogle');
    const clientId =
        "303325207155-rufs5fqkaggkn4c19bsrjbsd6abb2nmt.apps.googleusercontent.com";
    const redirectUri = "https://hanakoleah.site/auth/google/redirect";

    const authUrl = "https://accounts.google.com/o/oauth2/auth?"
        "client_id=$clientId&"
        "redirect_uri=$redirectUri&"
        "response_type=code&"
        "scope=openid email profile";

    // Open the browser for Google Sign-In
    final result = await FlutterWebAuth.authenticate(
      url: authUrl,
      callbackUrlScheme: "hanakoleh",
    );

    // Extract the authorization code from the callback URL
    final code = Uri.parse(result).queryParameters['code'];
    print('code = $code');
    if (code != null) {
      await getAccessToken(code);
    }
  }

  Future<void> getAccessToken(String code) async {
    print('getAccessToken');
    final response = await http.post(
      Uri.parse("https://oauth2.googleapis.com/token"),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        "client_id":
            "303325207155-rufs5fqkaggkn4c19bsrjbsd6abb2nmt.apps.googleusercontent.com",
        "client_secret": "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",
        "code": code,
        "grant_type": "authorization_code",
        "redirect_uri": "https://hanakoleah.site/auth/google/redirect",
      },
    );

    final data = json.decode(response.body);
    final accessToken = data["access_token"];

    if (accessToken != null) {
      print('nottttttttttttttt nulllllllllllll');
      await getUserInfo(accessToken);
    }
  }

  Future<void> getUserInfo(String accessToken) async {
    print('getUserInfo');
    final response = await http.get(
      Uri.parse("https://www.googleapis.com/oauth2/v2/userinfo"),
      headers: {"Authorization": "Bearer $accessToken"},
    );

    final userInfo = json.decode(response.body);
    print("User Info: $userInfo");
  }

  _launchURL() async {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) async {
            print('Page finished loading: $url');
            if (url.contains('/auth/google/callback')) {
              var response = await _controller.runJavaScriptReturningResult(
                  'document.getElementById("response").innerText');
              print('response ==$response');
              print('moooooooo');
              if (response is String) {
                print('zeinab');
                try {
                  final responseData = jsonDecode(response);
                  if (responseData['message'] == 'Login successful') {
                    String accessToken = responseData['access_token'];
                    await storage.write(
                        key: 'access_token', value: accessToken);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Login successful! Token stored.')),
                    );
                    Navigator.pop(context); // Close WebView
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Login failed: ${responseData['error']}')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error parsing response: $e')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Unexpected response format')),
                );
              }
            }
          },
          onWebResourceError: (WebResourceError error) {
            print('WebView error: $error');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to load page')),
            );
          },
        ),
      );

    await _controller
        .loadRequest(Uri.parse('https://hanakoleah.site/auth/google/redirect'));
  }

  //  _launchURL() async {
  //   _controller = WebViewController()
  //     ..setJavaScriptMode(JavaScriptMode.unrestricted)
  //     ..setBackgroundColor(const Color(0x00000000))
  //     ..setNavigationDelegate(
  //       NavigationDelegate(
  //         onPageStarted: (String url) {
  //           print('Page started loading: $url');
  //         },
  //         onPageFinished: (String url) async {
  //           print('Page finished loading: $url');
  //           if (url.contains('/auth/google/callback')) {
  //             var response = await _controller.runJavaScript(
  //                 'document.getElementById("response").innerText');
  //             print('Callback response: $response');
  //
  //             try {
  //               final responseData = jsonDecode(response);
  //               if (responseData['message'] == 'Login successful') {
  //                 String accessToken = responseData['access_token'];
  //                 await storage.write(key: 'access_token', value: accessToken);
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   SnackBar(content: Text('Login successful! Token stored.')),
  //                 );
  //                 Navigator.pop(context); // Close WebView
  //               } else {
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   SnackBar(content: Text('Login failed: ${responseData['error']}')),
  //                 );
  //               }
  //             } catch (e) {
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 SnackBar(content: Text('Error parsing response: $e')),
  //               );
  //             }
  //           }
  //         },
  //         onWebResourceError: (WebResourceError error) {
  //           print('WebView error: $error');
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(content: Text('Failed to load page')),
  //           );
  //         },
  //       ),
  //     );
  //   await _controller.loadRequest(
  //       Uri.parse('https://hanakoleah.site/auth/google/redirect'));// Updated to your route
  //   // final Uri url = Uri.parse("https://hanakoleah.site/auth/google/redirect");
  //   // if (await canLaunchUrl(url)) {
  //   //   print('url open success');
  //   //   await launchUrl(url);
  //   //   //_listenForCallback();
  //   // } else {
  //   //   throw "Could not launch $url";
  //   // }
  // }
}
