import 'package:flutter/material.dart';

class ErrorText extends StatelessWidget {
  final String errortxt;
  const ErrorText({super.key, required this.errortxt});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(errortxt),
    );
  }
}
