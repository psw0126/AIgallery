/*
 * Copyright (C) 2021 NerdSpace, Inc. All Rights Reserved.
 *
 * Authors:
 *  Donam Kim <donam.kim@nerdspace.co.kr>
 *  Miji Cha <miji.cha@nerdspace.co.kr>
 *  Jaekyung Oh <jaekyung.oh@nerdspace.co.kr>
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../wiget/button.dart';

class CustomAlert extends StatelessWidget {
  final String message;
  final String btnText;
  final Function? onTap;

  CustomAlert(this.message, this.btnText, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: FittedBox(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          width: MediaQuery.of(context).size.width - (28.0 * 2.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.all(
              const Radius.circular(12.0),
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 30.0),
              Text(this.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20.0)),
              SizedBox(height: 22.0),
              Container(
                width: double.infinity,
                child: CustomButton(this.btnText,
                    textColor: Colors.white, height: 52.0, onTap: () {
                  if (this.onTap != null) {
                    this.onTap!();
                  }
                  Modular.to.pop();
                  // Navigator.of(context).pop();
                }),
              ),
              SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}

void alert(BuildContext context, String message, String buttonText,
    {Function? onTap}) {
  showDialog(
      context: context,
      // check - d4231 2021.10.1
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomAlert(message, buttonText, onTap: onTap);
      });
}
