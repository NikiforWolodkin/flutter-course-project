import 'package:flutter/cupertino.dart';
import 'package:flutter_application_ecommerce/Model/Tools/Color/color.dart';
import 'package:google_fonts/google_fonts.dart' as fonts;

class CustomTextStyle {
  final CustomColors colors = CustomColors();
  
  late TextStyle bodyNormal =
      fonts.GoogleFonts.montserrat().copyWith(fontSize: 20, color: colors.blackColor);

  late TextStyle bodySmall =
      fonts.GoogleFonts.montserrat().copyWith(fontSize: 14, color: colors.captionColor);

  late TextStyle titleLarge = fonts.GoogleFonts.montserrat().copyWith(
      fontSize: 30, color: colors.blackColor, fontWeight: FontWeight.bold);
}

