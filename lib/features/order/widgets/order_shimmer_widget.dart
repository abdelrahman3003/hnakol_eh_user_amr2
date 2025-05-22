import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class OrderShimmerWidget extends StatelessWidget {
  final OrderController orderController;
  const OrderShimmerWidget({super.key, required this.orderController});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: Dimensions.webMaxWidth,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeLarge,
            mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : 0,
            crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 2,
            mainAxisExtent: ResponsiveHelper.isDesktop(context) ? 130 : 115,
          ),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge) : const EdgeInsets.all(Dimensions.paddingSizeSmall),
          itemCount: 10,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
              child: Center(
                child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
                    ),
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: Shimmer(
                      duration: const Duration(seconds: 2),
                      enabled: orderController.runningOrderList == null,
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

                        Row(children: [
                          Container(
                            height: ResponsiveHelper.isDesktop(context) ? 80 : 50, width: ResponsiveHelper.isDesktop(context) ? 80 : 50,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Colors.grey[300]),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Container(height: 15, width: 100, color: Colors.grey[300]),
                            const SizedBox(height: Dimensions.paddingSizeSmall),
                            Container(height: 15, width: 150, color: Colors.grey[300]),
                          ])),
                          Column(children: [
                            !ResponsiveHelper.isDesktop(context) ? Container(
                              height: 20, width: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                color: Colors.grey[300],
                              ),
                            ) : const SizedBox(),
                            const SizedBox(height: Dimensions.paddingSizeSmall),
                            Container(
                              height: 20, width: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                color: Colors.grey[300],
                              ),
                            )
                          ]),
                        ]),

                      ]),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
