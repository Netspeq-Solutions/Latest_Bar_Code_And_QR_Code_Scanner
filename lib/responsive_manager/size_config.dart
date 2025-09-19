/*
import 'package:flutter/material.dart';

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static Orientation? orientation;
  static late double pixelRatio;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    orientation = _mediaQueryData.orientation;
    pixelRatio = _mediaQueryData.devicePixelRatio;
  }

  static double getWidthForPercentage(double percentage) {
    if (percentage > 0 && percentage <= 100) {
      return screenWidth * (percentage / 100);
    } else {
      return screenWidth;
    }
  }

  static double getHeightForPercentage(double percentage) {
    if (percentage > 0 && percentage <= 100) {
      return screenHeight * (percentage / 100.0);
    } else {
      return screenHeight;
    }
  }


  // Get the proportionate height as per screen size
 static double getProportionateScreenHeight(double inputHeight) {
    double screenHeight = SizeConfig.screenHeight;
    // 812 is the layout height that designers use
    return (inputHeight / 812.0) * screenHeight;
  }

// Get the proportionate height as per screen size
 static double getProportionateScreenWidth(double inputWidth) {
    double screenWidth = SizeConfig.screenWidth;
    // 375 is the layout width that designers use
    return (inputWidth / 375.0) * screenWidth;
  }

  static double getPixelRatio() => pixelRatio;

  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return baseFontSize * 0.8;
    } else if (screenWidth < 1200) {
      return baseFontSize;
    } else {
      return baseFontSize * 1.2;
    }
  }
}
*/



import 'package:flutter/material.dart';

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static double? defaultSize;
  static Orientation? orientation;
  static late double pixelRatio;


  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    orientation = _mediaQueryData.orientation;
    pixelRatio = _mediaQueryData.devicePixelRatio;
  }
}

bool isTablet(BuildContext context) {
  final size = MediaQuery.of(context).size;
  final shortestSide = size.shortestSide;
  return shortestSide >= 600;
}


// Get the proportionate height as per screen size
double getProportionateScreenHeight(double inputHeight) {
  double screenHeight = SizeConfig.screenHeight;
  // 812 is the layout height that designers use
  return (inputHeight / 812.0) * screenHeight;
}

// Get the proportionate height as per screen size
double getProportionateScreenWidth(double inputWidth) {
  double screenWidth = SizeConfig.screenWidth;
  // 375 is the layout width that designers use
  return (inputWidth / 375.0) * screenWidth;
}

 double getWidthForPercentage(double percentage) {
  if (percentage > 0 && percentage <= 100) {
    return SizeConfig.screenWidth * (percentage / 100);
  } else {
    return SizeConfig.screenWidth;
  }
}

double getHeightForPercentage(double percentage) {
  if (percentage > 0 && percentage <= 100) {
    return SizeConfig.screenHeight * (percentage / 100.0);
  } else {
    return SizeConfig.screenHeight;
  }
}

double getPixelRatio() {
  return SizeConfig.pixelRatio;
}

double getResponsiveFontSize(BuildContext context, double baseFontSize) {
// Get the screen width
  double screenWidth = MediaQuery.of(context).size.width;

// You can set breakpoints based on your design and adjust the font size accordingly
  if (screenWidth<600) {
// Small screen size
    return baseFontSize * 0.8; // Adjust the factor as needed
  } else if (screenWidth<1200) {
// Medium screen size
    return baseFontSize;
  } else {
// Large screen size
    return baseFontSize * 1.2; // Adjust the factor as needed
  }
}
