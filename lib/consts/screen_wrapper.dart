import 'package:flutter/material.dart';

import 'app_spacing.dart';
import 'colors.dart';

class ScreenWrapper extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final bool useSafeArea;
  final Color backgroundColor;

  const ScreenWrapper({
    super.key,
    required this.body,
    this.appBar,
    this.useSafeArea = true,
    this.backgroundColor = AppColors.background,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: AppSpacing.screenPadding,
      child: body,
    );

    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      body: content,
    );
  }
}
