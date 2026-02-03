import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SafeSnackbarHelper {
  /// Safe method to show snackbar that checks for overlay context
  static void showSafeSnackbar({
    required String title,
    required String message,
    Color? backgroundColor,
    Color? colorText,
    Duration? duration,
    SnackPosition? snackPosition,
    EdgeInsets? margin,
    Icon? icon,
    bool? shouldIconPulse,
    double? borderRadius,
    double? maxWidth,
  }) {
    // Add delay to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _attemptShowSnackbar(
        title: title,
        message: message,
        backgroundColor: backgroundColor,
        colorText: colorText,
        duration: duration,
        snackPosition: snackPosition,
        margin: margin,
        icon: icon,
        shouldIconPulse: shouldIconPulse,
        borderRadius: borderRadius,
        maxWidth: maxWidth,
        retryCount: 0,
      );
    });
  }
  
  static void _attemptShowSnackbar({
    required String title,
    required String message,
    Color? backgroundColor,
    Color? colorText,
    Duration? duration,
    SnackPosition? snackPosition,
    EdgeInsets? margin,
    Icon? icon,
    bool? shouldIconPulse,
    double? borderRadius,
    double? maxWidth,
    int retryCount = 0,
  }) {
    const maxRetries = 5;
    
    // Check if Get context is available
    if (Get.context == null) {
      print('⚠️ [SNACKBAR] No Get context available (attempt ${retryCount + 1})');
      if (retryCount < maxRetries) {
        Future.delayed(Duration(milliseconds: 200 * (retryCount + 1)), () {
          _attemptShowSnackbar(
            title: title,
            message: message,
            backgroundColor: backgroundColor,
            colorText: colorText,
            duration: duration,
            snackPosition: snackPosition,
            margin: margin,
            icon: icon,
            shouldIconPulse: shouldIconPulse,
            borderRadius: borderRadius,
            maxWidth: maxWidth,
            retryCount: retryCount + 1,
          );
        });
      } else {
        print('❌ [SNACKBAR] Failed to show after $maxRetries attempts: $title - $message');
      }
      return;
    }
    
    // Additional safety check for MaterialApp
    try {
      final navigator = Navigator.maybeOf(Get.context!);
      if (navigator == null) {
        print('⚠️ [SNACKBAR] No Navigator found (attempt ${retryCount + 1})');
        if (retryCount < maxRetries) {
          Future.delayed(Duration(milliseconds: 200 * (retryCount + 1)), () {
            _attemptShowSnackbar(
              title: title,
              message: message,
              backgroundColor: backgroundColor,
              colorText: colorText,
              duration: duration,
              snackPosition: snackPosition,
              margin: margin,
              icon: icon,
              shouldIconPulse: shouldIconPulse,
              borderRadius: borderRadius,
              maxWidth: maxWidth,
              retryCount: retryCount + 1,
            );
          });
        } else {
          print('❌ [SNACKBAR] No Navigator after $maxRetries attempts: $title - $message');
        }
        return;
      }
    } catch (e) {
      print('⚠️ [SNACKBAR] Navigator check failed (attempt ${retryCount + 1}): $e');
      if (retryCount < maxRetries) {
        Future.delayed(Duration(milliseconds: 200 * (retryCount + 1)), () {
          _attemptShowSnackbar(
            title: title,
            message: message,
            backgroundColor: backgroundColor,
            colorText: colorText,
            duration: duration,
            snackPosition: snackPosition,
            margin: margin,
            icon: icon,
            shouldIconPulse: shouldIconPulse,
            borderRadius: borderRadius,
            maxWidth: maxWidth,
            retryCount: retryCount + 1,
          );
        });
      } else {
        print('❌ [SNACKBAR] Navigator error after $maxRetries attempts: $title - $message - $e');
      }
      return;
    }
    
    // Try to find overlay with additional safety
    try {
      final overlay = Overlay.maybeOf(Get.context!);
      if (overlay == null) {
        print('⚠️ [SNACKBAR] No overlay found (attempt ${retryCount + 1})');
        if (retryCount < maxRetries) {
          Future.delayed(Duration(milliseconds: 200 * (retryCount + 1)), () {
            _attemptShowSnackbar(
              title: title,
              message: message,
              backgroundColor: backgroundColor,
              colorText: colorText,
              duration: duration,
              snackPosition: snackPosition,
              margin: margin,
              icon: icon,
              shouldIconPulse: shouldIconPulse,
              borderRadius: borderRadius,
              maxWidth: maxWidth,
              retryCount: retryCount + 1,
            );
          });
        } else {
          print('❌ [SNACKBAR] No overlay after $maxRetries attempts: $title - $message');
        }
        return;
      }
    } catch (e) {
      print('⚠️ [SNACKBAR] Overlay check failed (attempt ${retryCount + 1}): $e');
      if (retryCount < maxRetries) {
        Future.delayed(Duration(milliseconds: 200 * (retryCount + 1)), () {
          _attemptShowSnackbar(
            title: title,
            message: message,
            backgroundColor: backgroundColor,
            colorText: colorText,
            duration: duration,
            snackPosition: snackPosition,
            margin: margin,
            icon: icon,
            shouldIconPulse: shouldIconPulse,
            borderRadius: borderRadius,
            maxWidth: maxWidth,
            retryCount: retryCount + 1,
          );
        });
      } else {
        print('❌ [SNACKBAR] Overlay error after $maxRetries attempts: $title - $message - $e');
      }
      return;
    }
    
    // Context and overlay are available, show immediately
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: backgroundColor,
      colorText: colorText,
      duration: duration,
      snackPosition: snackPosition,
      margin: margin,
      icon: icon,
      shouldIconPulse: shouldIconPulse,
      borderRadius: borderRadius,
      maxWidth: maxWidth,
    );
  }
  
  static void _showSnackbar({
    required String title,
    required String message,
    Color? backgroundColor,
    Color? colorText,
    Duration? duration,
    SnackPosition? snackPosition,
    EdgeInsets? margin,
    Icon? icon,
    bool? shouldIconPulse,
    double? borderRadius,
    double? maxWidth,
  }) {
    try {
      Get.snackbar(
        title,
        message,
        backgroundColor: backgroundColor,
        colorText: colorText,
        duration: duration ?? const Duration(seconds: 3),
        snackPosition: snackPosition ?? SnackPosition.TOP,
        margin: margin ?? const EdgeInsets.all(10),
        icon: icon,
        shouldIconPulse: shouldIconPulse,
        borderRadius: borderRadius,
        maxWidth: maxWidth,
      );
    } catch (e) {
      print('❌ [SNACKBAR] Failed to show snackbar: $e');
      print('   Title: $title');
      print('   Message: $message');
    }
  }
}