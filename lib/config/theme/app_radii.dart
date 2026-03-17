import 'package:flutter/material.dart';

abstract final class AppRadii {
  static const double small = 8;
  static const double medium = 10;
  static const double large = 12;
  static const double xLarge = 14;
  static const double card = 16;
  static const double panel = 24;
  static const double input = 40;
  static const double avatar = 32;
  static const double pill = 999;

  static const BorderRadius smallRadius = BorderRadius.all(
    Radius.circular(small),
  );

  static const BorderRadius mediumRadius = BorderRadius.all(
    Radius.circular(medium),
  );

  static const BorderRadius largeRadius = BorderRadius.all(
    Radius.circular(large),
  );

  static const BorderRadius xLargeRadius = BorderRadius.all(
    Radius.circular(xLarge),
  );

  static const BorderRadius cardRadius = BorderRadius.all(
    Radius.circular(card),
  );

  static const BorderRadius panelRadius = BorderRadius.all(
    Radius.circular(panel),
  );

  static const BorderRadius inputRadius = BorderRadius.all(
    Radius.circular(input),
  );

  static const BorderRadius avatarRadius = BorderRadius.all(
    Radius.circular(avatar),
  );

  static const BorderRadius pillRadius = BorderRadius.all(
    Radius.circular(pill),
  );

  static BorderRadius circular(double value) =>
      BorderRadius.all(Radius.circular(value));
}
