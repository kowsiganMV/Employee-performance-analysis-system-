import 'package:flutter/material.dart';

class ErrorMessageWidget extends StatefulWidget {
  final bool showError;
  final String errormsg;

  ErrorMessageWidget({Key? key, required this.showError, required this.errormsg}) : super(key: key);

  @override
  _ErrorMessageWidgetState createState() => _ErrorMessageWidgetState();
}

class _ErrorMessageWidgetState extends State<ErrorMessageWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.showError
        ? Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        widget.errormsg,
        style: TextStyle(color: Colors.red, fontSize: 16),
      ),
    )
        : SizedBox.shrink();
  }
}