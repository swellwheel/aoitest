import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';


Future<void> getCurrentLocation(List<double> coordinates) async {
    bool serviceEnabled;
    LocationPermission permission;

    // 確認定位服務是否開啟
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {//定位服務未開啟'
      return;
    }

    // 確認定位權限
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {//'定位權限被拒絕'
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {//'定位權限被永久拒絕，無法取得定位'
      return;
    }

    // 取得目前位置
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    coordinates[0] = position.longitude;
    coordinates[1] = position.latitude;
  ;
  }