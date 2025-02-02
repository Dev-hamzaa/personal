
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class AppSizes {
  static double size12 = 12,
      size14 = 14,
      size16 = 16,
      size18 = 18,
      size20 = 20,
      size22 = 22,
      size32 = 32;
}


// class Appfonts{
//   static const nunito="nunito", nunitoBold="nunito_bold";
// }



class AppStyle{
  // ignore: avoid_types_as_parameter_names
  static  normal({String? title,Color? color=Colors.black,double? size}){
    return title!.text.size(size).color(color).make();
  }


  // static  bold({String? title,Color? color=Colors.black,double? size}){
  //  return  title!.text.size(size).color(color).fontFamily(AppStyle.bold()).make();
  // }
}