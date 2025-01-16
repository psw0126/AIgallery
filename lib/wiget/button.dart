
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final double? width;
  final double? height;
  final Function? onTap;
  final Color? backgroundColor;
  final Color? textColor;

  CustomButton(this.text, {this.width, this.height, this.onTap, this.backgroundColor, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 52.0),
      child: InkWell(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        child: Container(
          alignment: Alignment.center,
          width: this.width ?? double.infinity,
          height: this.height ?? double.infinity,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.7),
                blurRadius: 5,
                offset: Offset(0, 3),
              )
            ],
            // color: Color(0xffFDAD8B),
            color: Color(0xffFFE4B5),
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          child: Text(
            this.text,
            style: TextStyle(
              color: this.textColor == null ? Colors.white : this.textColor,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        onTap: () {
          if (this.onTap != null) {
            this.onTap!();
          }
        },
      ),
    );
  }
}