import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

AppBar getAppBar(String title) {
  return AppBar(
    backgroundColor: Colors.grey[800],
    title: Text(
      title,
      style: TextStyle(
        fontSize: 15.0.sp,
      ),
    ),
    elevation: 10,
    centerTitle: true,
  );
}
