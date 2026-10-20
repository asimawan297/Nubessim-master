import 'package:another_flushbar/flushbar.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:nubesim/constants/app_colors.dart';
import 'package:nubesim/generated/assets.dart';

import '../../ui/widgets/loading_indicator.dart';

class DisplayUtils {
  static void showSnackBar(BuildContext context, String title,
      {type = "failed",Color bgColor = AppColors.primaryColor}) {
    IconSnackBar.show(context,
        snackBarType:
            type == "failed" ? SnackBarType.fail : SnackBarType.success,
        maxLines: 5,
        label: title,
        backgroundColor: bgColor);
  }

  static void showToast(BuildContext context, String title) {
    // Fluttertoast.showToast(
    //     msg: title,
    //     toastLength: Toast.LENGTH_SHORT,
    //     gravity: ToastGravity.BOTTOM,
    //     timeInSecForIosWeb: 1,
    //     backgroundColor: AppColors.white,
    //     textColor: AppColors.black,
    //     fontSize: 16.0);

    Flushbar(
  message: title,
  duration: Duration(seconds: 2),
  backgroundColor: AppColors.white,
  showProgressIndicator: true,
  messageColor: AppColors.black,
  borderRadius: BorderRadius.circular(50),
  margin: EdgeInsets.all(16),
  flushbarPosition: FlushbarPosition.BOTTOM,
  icon: Image.asset(Assets.logo)
).show(context);
  }

  static void showLoader() {
    BotToast.showCustomLoading(toastBuilder: (_) => const LoadingIndicator());
  }

  static void removeLoader() {
    BotToast.closeAllLoading();
  }
}
