import 'package:flutter/material.dart';

class ResponsiveUtils {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 768 &&
        MediaQuery.of(context).size.width < 1024;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  static double getSidebarWidth(BuildContext context) {
    if (isMobile(context)) {
      return MediaQuery.of(context).size.width * 0.8;
    }
    return 280;
  }
}