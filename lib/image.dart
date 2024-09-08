import 'dart:convert'; // 用于 base64Encode
import 'dart:io'; // 用于 File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';



Future<String> pickImage() async {
  final ImagePicker picker = ImagePicker();
  final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    // 读取图像文件并转换为 BASE64 字符串
    final bytes = await pickedFile.readAsBytes();
    return base64Encode(bytes);
    
  }
  else  
    return '';
}

