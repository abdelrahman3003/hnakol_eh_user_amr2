import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/place_order_body_model.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/place_order_body_model.dart' as place_order_model;
import 'package:stackfood_multivendor/features/checkout/domain/models/pricing_view_model.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/payment_method_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/coupon/controllers/coupon_controller.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_model.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/shared_file.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../helper/custom_validator.dart';

class OrderPlaceButton extends StatefulWidget {
  final CheckoutController checkoutController;
  final LocationController locationController;
  final bool todayClosed;
  final bool tomorrowClosed;
  final double orderAmount;
  final double? deliveryCharge;
  final double tax;
  final double? discount;
  final double total;
  final double? maxCodOrderAmount;
  final int subscriptionQty;
  final List<CartModel> cartList;
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isOfflinePaymentActive;
  final bool isWalletActive;
  final bool fromCart;
  final TextEditingController guestNameTextEditingController;
  final TextEditingController guestNumberTextEditingController;
  final TextEditingController guestEmailController;
  final FocusNode guestNumberNode;
  final FocusNode guestEmailNode;
  final CouponController couponController;
  final double subTotal;
  final bool taxIncluded;
  final double taxPercent;


  const OrderPlaceButton({
    super.key, required this.checkoutController, required this.locationController,
    required this.todayClosed, required this.tomorrowClosed, required this.orderAmount, this.deliveryCharge,
    required this.tax, this.discount, required this.total, this.maxCodOrderAmount, required this.subscriptionQty,
    required this.cartList, required this.isCashOnDeliveryActive, required this.isDigitalPaymentActive,
    required this.isWalletActive, required this.fromCart, required this.guestNameTextEditingController, required this.guestNumberTextEditingController,
    required this.guestNumberNode, required this.isOfflinePaymentActive, required this.couponController, required this.subTotal,
    required this.taxIncluded, required this.taxPercent, required this.guestEmailController,
    required this.guestEmailNode});

  @override
  State<OrderPlaceButton> createState() => _OrderPlaceButtonState();
}

class _OrderPlaceButtonState extends State<OrderPlaceButton> {
  @override
  Widget build(BuildContext context) {
    print('sharedPrefs.getPhone()== ${sharedPrefs.getPhone()}');
    return Container(
      width: Dimensions.webMaxWidth,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      child: SafeArea(
        child: CustomButtonWidget(
            buttonText: widget.checkoutController.isPartialPay ? 'place_order'.tr : 'confirm_order'.tr,
            radius: Dimensions.radiusDefault,
            isLoading: widget.checkoutController.isLoading,
            onPressed: () async{
              print('confirm order');
              DateTime scheduleStartDate = _processScheduleStartDate();
              DateTime scheduleEndDate = _processScheduleEndDate();
              bool isAvailable = _checkAvailability(scheduleStartDate, scheduleEndDate);
              bool isGuestLogIn = Get.find<AuthController>().isGuestLoggedIn();
              bool datePicked = _isDatePicked();

                  if(widget.checkoutController.isDmTipSave && widget.checkoutController.selectedTips != AppConstants.tips.length - 1) {
                    Get.find<AuthController>().saveDmTipIndex(widget.checkoutController.selectedTips.toString());
                  }
                  if(!widget.checkoutController.isDmTipSave){
                    Get.find<AuthController>().saveDmTipIndex('0');
                  }

                  if(await _showsWarningMessage(context, isGuestLogIn, datePicked, isAvailable)){
                    debugPrint('Warning shows');
                  } else {

                    AddressModel? finalAddress = _processFinalAddress(isGuestLogIn);
                    List<place_order_model.OnlineCart> carts = _generateOnlineCartList();
                    List<place_order_model.SubscriptionDays> days = _generateSubscriptionDays();

                    PlaceOrderBodyModel placeOrderBody = _preparePlaceOrderModel(carts, scheduleStartDate, finalAddress, isGuestLogIn, days);
                    if(widget.checkoutController.paymentMethodIndex == 3){
                      Get.toNamed(RouteHelper.getOfflinePaymentScreen(placeOrderBody: placeOrderBody, zoneId: widget.checkoutController.restaurant!.zoneId!, total: widget.total, maxCodOrderAmount: widget.maxCodOrderAmount,
                        fromCart: widget.fromCart, isCodActive: widget.isCashOnDeliveryActive,
                        pricingView: PricingViewModel(
                          subTotal: widget.subTotal, subscriptionQty: widget.subscriptionQty, discount: widget.discount!, taxIncluded: widget.taxIncluded,
                          tax: widget.tax, deliveryCharge: widget.deliveryCharge!, total: widget.total, taxPercent: widget.taxPercent,
                        ),
                      ));
                    }else{
                      widget.checkoutController.placeOrder(placeOrderBody, widget.checkoutController.restaurant!.zoneId!, widget.total, widget.maxCodOrderAmount, widget.fromCart, widget.isCashOnDeliveryActive);
                    }
                  }
                }

        ),
      ),
    );
  }

  bool _isDatePicked() {
    bool datePicked = false;
    for(DateTime? time in widget.checkoutController.selectedDays) {
      if(time != null) {
        datePicked = true;
        break;
      }
    }
    return datePicked;
  }

  DateTime _processScheduleStartDate() {
    DateTime scheduleStartDate = DateTime.now();
    if(widget.checkoutController.timeSlots != null || widget.checkoutController.timeSlots!.isNotEmpty) {
      DateTime date = widget.checkoutController.selectedDateSlot == 0 ? DateTime.now()
          : widget.checkoutController.selectedDateSlot == 1 ? DateTime.now().add(const Duration(days: 1)) : widget.checkoutController.selectedCustomDate?? DateTime.now();
      DateTime startTime = widget.checkoutController.timeSlots![widget.checkoutController.selectedTimeSlot!].startTime!;
      scheduleStartDate = DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute+1);
    }
    return scheduleStartDate;
  }

  DateTime _processScheduleEndDate() {
    DateTime scheduleEndDate = DateTime.now();
    if(widget.checkoutController.timeSlots != null || widget.checkoutController.timeSlots!.isNotEmpty) {
      DateTime date = widget.checkoutController.selectedDateSlot == 0 ? DateTime.now()
          : widget.checkoutController.selectedDateSlot == 1 ? DateTime.now().add(const Duration(days: 1)) : widget.checkoutController.selectedCustomDate?? DateTime.now();
      DateTime endTime = widget.checkoutController.timeSlots![widget.checkoutController.selectedTimeSlot!].endTime!;
      scheduleEndDate = DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute+1);
    }
    return scheduleEndDate;
  }

  bool _checkAvailability(DateTime scheduleStartDate, DateTime scheduleEndDate) {
    bool isAvailable = true;
    if(widget.checkoutController.timeSlots == null || widget.checkoutController.timeSlots!.isEmpty) {
      isAvailable = false;
    } else {
      for (CartModel cart in widget.cartList) {
        if (!DateConverter.isAvailable(
          cart.product!.availableTimeStarts, cart.product!.availableTimeEnds,
          time: widget.checkoutController.restaurant!.scheduleOrder! ? scheduleStartDate : null,
        ) && !DateConverter.isAvailable(
          cart.product!.availableTimeStarts, cart.product!.availableTimeEnds,
          time: widget.checkoutController.restaurant!.scheduleOrder! ? scheduleEndDate : null,
        )) {
          isAvailable = false;
          break;
        }
      }
    }
    return isAvailable;
  }

Future<bool> _showsWarningMessage(BuildContext context, bool isGuestLogIn, bool datePicked, bool isAvailable) async {
  if (isGuestLogIn && widget.checkoutController.guestAddress == null && widget.checkoutController.orderType != 'take_away') {
    showCustomSnackBar('please_setup_your_delivery_address_first'.tr);
    return true;
  } else if (isGuestLogIn && widget.checkoutController.orderType == 'take_away' && widget.guestNameTextEditingController.text.isEmpty) {
    showCustomSnackBar('please_enter_contact_person_name'.tr);
    return true;
  } else if (isGuestLogIn && widget.checkoutController.orderType == 'take_away' && widget.guestNumberTextEditingController.text.isEmpty) {
    showCustomSnackBar('please_enter_contact_person_number'.tr);
    return true;
  } else if (!widget.isCashOnDeliveryActive && !widget.isDigitalPaymentActive && !widget.isWalletActive) {
    showCustomSnackBar('no_payment_method_is_enabled'.tr);
    return true;
  } else if (!Get.find<SplashController>().configModel!.instantOrder! &&
      !widget.checkoutController.restaurant!.instantOrder! &&
      widget.checkoutController.restaurant!.scheduleOrder! &&
      (widget.checkoutController.preferableTime.isEmpty || widget.checkoutController.preferableTime == 'Not Available')) {
    showCustomSnackBar('please_select_order_preference_time'.tr);
    return true;
  } else if (widget.checkoutController.paymentMethodIndex == -1) {
    if (ResponsiveHelper.isDesktop(context)) {
      Get.dialog(Dialog(
          backgroundColor: Colors.transparent,
          child: PaymentMethodBottomSheet(
            isCashOnDeliveryActive: widget.isCashOnDeliveryActive,
            isDigitalPaymentActive: widget.isDigitalPaymentActive,
            isWalletActive: widget.isWalletActive,
            totalPrice: widget.total,
            isOfflinePaymentActive: widget.isOfflinePaymentActive,
          )));
    } else {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (con) => PaymentMethodBottomSheet(
            isCashOnDeliveryActive: widget.isCashOnDeliveryActive,
            isDigitalPaymentActive: widget.isDigitalPaymentActive,
            isWalletActive: widget.isWalletActive,
            totalPrice: widget.total,
            isOfflinePaymentActive: widget.isOfflinePaymentActive,
          ),
        );


    }
    return true;
  } else if (widget.orderAmount < widget.checkoutController.restaurant!.minimumOrder!) {
    showCustomSnackBar('${'minimum_order_amount_is'.tr} ${widget.checkoutController.restaurant!.minimumOrder}');
    return true;
  } else if (widget.checkoutController.subscriptionOrder && widget.checkoutController.subscriptionRange == null) {
    showCustomSnackBar('select_a_date_range_for_subscription'.tr);
    return true;
  } else if (widget.checkoutController.subscriptionOrder && !datePicked && widget.checkoutController.subscriptionType == 'daily') {
    showCustomSnackBar('choose_time'.tr);
    return true;
  } else if (widget.checkoutController.subscriptionOrder && !datePicked) {
    showCustomSnackBar('select_at_least_one_day_for_subscription'.tr);
    return true;
  } else if ((widget.checkoutController.selectedDateSlot == 0 && widget.todayClosed) ||
      (widget.checkoutController.selectedDateSlot == 1 && widget.tomorrowClosed) ||
      (widget.checkoutController.selectedDateSlot == 2 && widget.checkoutController.customDateRestaurantClose)) {
    showCustomSnackBar('restaurant_is_closed'.tr);
    return true;
  } else if (widget.checkoutController.paymentMethodIndex == 0 &&
      Get.find<SplashController>().configModel!.cashOnDelivery! &&
      widget.maxCodOrderAmount != null &&
      (widget.total > widget.maxCodOrderAmount!)) {
    showCustomSnackBar('${'you_cant_order_more_then'.tr} ${PriceConverter.convertPrice(widget.maxCodOrderAmount)} ${'in_cash_on_delivery'.tr}');
    return true;
  } else if (widget.checkoutController.timeSlots == null || widget.checkoutController.timeSlots!.isEmpty) {
    if (widget.checkoutController.restaurant!.scheduleOrder! && !widget.checkoutController.subscriptionOrder) {
      showCustomSnackBar('select_a_time'.tr);
    } else {
      showCustomSnackBar('restaurant_is_closed'.tr);
    }
    return true;
  } else if (!isAvailable && !widget.checkoutController.subscriptionOrder) {
    showCustomSnackBar('one_or_more_products_are_not_available_for_this_selected_time'.tr);
    return true;
  } else if (widget.checkoutController.orderType != 'take_away' &&
      widget.checkoutController.distance == -1 &&
      widget.deliveryCharge == -1) {
    showCustomSnackBar('delivery_fee_not_set_yet'.tr);
    return true;
  } else if (widget.checkoutController.paymentMethodIndex == 1 &&
      Get.find<ProfileController>().userInfoModel != null &&
      Get.find<ProfileController>().userInfoModel!.walletBalance! < widget.total) {
    showCustomSnackBar('you_do_not_have_sufficient_balance_in_wallet'.tr);
    return true;
  } else {
    return false;
  }
}

  AddressModel? _processFinalAddress(bool isGuestLogIn) {
    AddressModel? finalAddress = isGuestLogIn ? widget.checkoutController.guestAddress : widget.checkoutController.address[widget.checkoutController.addressIndex];

    if(isGuestLogIn && widget.checkoutController.orderType == 'take_away') {
      String number = widget.checkoutController.countryDialCode! + widget.guestNumberTextEditingController.text;
      finalAddress = AddressModel(contactPersonName: widget.guestNameTextEditingController.text, contactPersonNumber: number,
        address: AddressHelper.getAddressFromSharedPref()!.address!, latitude: AddressHelper.getAddressFromSharedPref()!.latitude,
        longitude: AddressHelper.getAddressFromSharedPref()!.longitude, zoneId: AddressHelper.getAddressFromSharedPref()!.zoneId,
        email: widget.guestEmailController.text,
      );
    }

    if(!isGuestLogIn && finalAddress!.contactPersonNumber == 'null'){
      finalAddress.contactPersonNumber = Get.find<ProfileController>().userInfoModel!.phone;
    }
    return finalAddress;
  }

  List<place_order_model.OnlineCart> _generateOnlineCartList() {
    List<place_order_model.OnlineCart> carts = [];
    for (int index = 0; index < widget.cartList.length; index++) {
      CartModel cart = widget.cartList[index];
      List<int?> addOnIdList = [];
      List<int?> addOnQtyList = [];
      List<place_order_model.OrderVariation> variations = [];
      for (var addOn in cart.addOnIds!) {
        addOnIdList.add(addOn.id);
        addOnQtyList.add(addOn.quantity);
      }
      if(cart.product!.variations != null){
        for(int i=0; i<cart.product!.variations!.length; i++) {
          if(cart.variations![i].contains(true)) {
            variations.add(place_order_model.OrderVariation(name: cart.product!.variations![i].name, values: place_order_model.OrderVariationValue(label: [])));
            for(int j=0; j<cart.product!.variations![i].variationValues!.length; j++) {
              if(cart.variations![i][j]!) {
                variations[variations.length-1].values!.label!.add(cart.product!.variations![i].variationValues![j].level);
              }
            }
          }
        }
      }
      carts.add(place_order_model.OnlineCart(
        cart.id, cart.product!.id, cart.isCampaign! ? cart.product!.id : null,
        cart.discountedPrice.toString(), variations,
        cart.quantity, addOnIdList, cart.addOns, addOnQtyList, 'Food', itemType: !widget.fromCart ? "AppModelsItemCampaign" : null,
      ));
    }
    return carts;
  }

  List<place_order_model.SubscriptionDays> _generateSubscriptionDays() {
    List<place_order_model.SubscriptionDays> days = [];
    for(int index=0; index<widget.checkoutController.selectedDays.length; index++) {
      if(widget.checkoutController.selectedDays[index] != null) {
        days.add(place_order_model.SubscriptionDays(
          day: widget.checkoutController.subscriptionType == 'weekly' ? (index == 6 ? 0 : (index + 1)).toString()
              : widget.checkoutController.subscriptionType == 'monthly' ? (index + 1).toString() : index.toString(),
          time: DateConverter.dateToTime(widget.checkoutController.selectedDays[index]!),
        ));
      }
    }
    return days;
  }

  PlaceOrderBodyModel _preparePlaceOrderModel(List<place_order_model.OnlineCart> carts, DateTime scheduleStartDate, AddressModel? finalAddress, bool isGuestLogIn, List<place_order_model.SubscriptionDays> days) {
    return PlaceOrderBodyModel(
      cart: carts, couponDiscountAmount: Get.find<CouponController>().discount, distance: widget.checkoutController.distance,
      couponDiscountTitle: Get.find<CouponController>().discount! > 0 ? Get.find<CouponController>().coupon!.title : null,
      scheduleAt: !widget.checkoutController.restaurant!.scheduleOrder! ? null : (widget.checkoutController.selectedDateSlot == 0
          && widget.checkoutController.selectedTimeSlot == 0) ? null : DateConverter.dateToDateAndTime(scheduleStartDate),
      orderAmount: widget.total, orderNote: widget.checkoutController.noteController.text, orderType: widget.checkoutController.orderType,
      paymentMethod: widget.checkoutController.paymentMethodIndex == 0 ? 'cash_on_delivery'
          : widget.checkoutController.paymentMethodIndex == 1 ? 'wallet'
          : widget.checkoutController.paymentMethodIndex == 2 ? 'digital_payment' : 'offline_payment',
      couponCode: (Get.find<CouponController>().discount! > 0 || (Get.find<CouponController>().coupon != null
          && Get.find<CouponController>().freeDelivery)) ? Get.find<CouponController>().coupon!.code : null,
      restaurantId: widget.cartList[0].product!.restaurantId,
      address: finalAddress!.address, latitude: finalAddress.latitude, longitude: finalAddress.longitude, addressType: finalAddress.addressType,
      contactPersonName: finalAddress.contactPersonName ?? '${Get.find<ProfileController>().userInfoModel!.fName} '
          '${Get.find<ProfileController>().userInfoModel!.lName}',
      contactPersonNumber: finalAddress.contactPersonNumber ?? Get.find<ProfileController>().userInfoModel!.phone,
      discountAmount: widget.discount, taxAmount: widget.tax, cutlery: Get.find<CartController>().addCutlery ? 1 : 0,
      road: isGuestLogIn ? finalAddress.road??'' : widget.checkoutController.streetNumberController.text.trim(),
      house: isGuestLogIn ? finalAddress.house??'' : widget.checkoutController.houseController.text.trim(),
      floor: isGuestLogIn ? finalAddress.floor??'' : widget.checkoutController.floorController.text.trim(),
      dmTips: (widget.checkoutController.orderType == 'take_away' || widget.checkoutController.subscriptionOrder || widget.checkoutController.selectedTips == 0) ? '' : widget.checkoutController.tips.toString(),
      subscriptionOrder: widget.checkoutController.subscriptionOrder ? '1' : '0',
      subscriptionType: widget.checkoutController.subscriptionType, subscriptionQuantity: widget.subscriptionQty.toString(),
      subscriptionDays: days,
      subscriptionStartAt: widget.checkoutController.subscriptionOrder ? DateConverter.dateToDateAndTime(widget.checkoutController.subscriptionRange!.start) : '',
      subscriptionEndAt: widget.checkoutController.subscriptionOrder ? DateConverter.dateToDateAndTime(widget.checkoutController.subscriptionRange!.end) : '',
      unavailableItemNote: Get.find<CartController>().notAvailableIndex != -1 ? Get.find<CartController>().notAvailableList[Get.find<CartController>().notAvailableIndex] : '',
      deliveryInstruction: widget.checkoutController.selectedInstruction != -1 ? AppConstants.deliveryInstructionList[widget.checkoutController.selectedInstruction] : '',
      partialPayment: widget.checkoutController.isPartialPay ? 1 : 0, guestId: isGuestLogIn ? int.parse(Get.find<AuthController>().getGuestId()) : 0,
      isBuyNow: widget.fromCart ? 0 : 1, guestEmail: isGuestLogIn ? finalAddress.email : null,
      phone: sharedPrefs.getPhone() =='' ?sharedPrefs.getPhone(): ''
    );
  }
}
