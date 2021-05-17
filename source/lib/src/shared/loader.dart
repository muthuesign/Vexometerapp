import 'package:flutter/material.dart';

class Loader {
  static bool isShown = false;
  static void show(BuildContext context, {String message}) {
    if (isShown) close(context);
    AlertDialog alert = AlertDialog(
       scrollable: true,
       backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
    borderRadius:
      BorderRadius.all(
        Radius.circular(10.0))),
       insetPadding: EdgeInsets.symmetric(horizontal: 90),
          contentPadding: EdgeInsets.zero,
          clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 0.0,
      content: Container(
            height: 70.0,
            width: 150,
            padding: EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.0)),
              Align(alignment: Alignment.center, child: Text(message ?? "Loading...", style: TextStyle(fontSize: 12.0),),),
            ]),
      ),
    );
    showDialog(barrierDismissible: false,
      context:context,
      builder:(BuildContext context){
        return alert;
      },
    );
    isShown = true;
  }

  static void close(BuildContext context) {
    if (isShown) {
      isShown = false;
      Navigator.pop(context);
    }
  }
}