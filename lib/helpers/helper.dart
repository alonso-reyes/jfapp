import 'package:flutter/material.dart';

pushAndRemoveUntil(BuildContext context, Widget destination, bool predict) {
  Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => destination),
      (Route<dynamic> route) => predict);
}

popRoute(BuildContext context, {result}) {
  Navigator.pop(context, result);
}
