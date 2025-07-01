//setup font variables
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nav_monitor/constants/colors.dart';

TextStyle get headline1 => GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: AppColors.primaryText,
    );

TextStyle get bodyText1 => GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.secondaryText,
    );
TextStyle get buttonText => GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: AppColors.buttonText,
    );
