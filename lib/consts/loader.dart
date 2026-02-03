import 'package:flutter/material.dart';

import 'colors.dart';

class AppLoader extends StatelessWidget {
  final String? message;

  const AppLoader({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      const CircularProgressIndicator(color: AppColors.primary),
    ];

    if (message != null) {
      children.addAll([
        const SizedBox(height: 12),
        Text(message!),
      ]);
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}
