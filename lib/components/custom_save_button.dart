import 'package:flutter/material.dart';
import 'package:jfapp/helpers/responsive_helper.dart';

class CustomSaveButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final double? width;
  final double? height;
  final double fontSize;
  final EdgeInsetsGeometry? margin;

  const CustomSaveButton({
    Key? key,
    required this.onPressed,
    this.text = 'Guardar',
    this.backgroundColor = Colors.black,
    this.textColor = Colors.white,
    this.width,
    this.height,
    this.fontSize = 15,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);

    return Center(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: height ?? responsive.dp(5),
          width: width ?? responsive.hp(13),
          margin: margin ?? EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
