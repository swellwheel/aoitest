import 'package:flutter/material.dart';
import "global.dart" as global;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import "detail_page.dart";
import 'info_card_data.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:ui' as ui;

String userid = global.user_id;

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  InfoCardData? _selectedMarkerData;
  LatLng? _currentLocation;
  BitmapDescriptor? _currentLocationIcon;
  @override
  void initState() {
    super.initState();
    _fetchAPIData();
    _getCurrentLocation();
    _createLargerCurrentLocationIcon();
  }
  Future<void> _createLargerCurrentLocationIcon() async {
    final ImageConfiguration imageConfig = ImageConfiguration(size: Size(48, 48));
    final ui.Codec codec = await ui.instantiateImageCodec(
      (await DefaultAssetBundle.of(context).load('assets/current_location_icon.png')).buffer.asUint8List(),
      targetWidth: 90,
      targetHeight: 120
    );
    final ui.FrameInfo fi = await codec.getNextFrame();
    final data = await fi.image.toByteData(format: ui.ImageByteFormat.png);

    if (data != null) {
      _currentLocationIcon = BitmapDescriptor.fromBytes(data.buffer.asUint8List());
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied, we cannot request permissions.');
        return;
      } 

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _addCurrentLocationMarker();
      });

      _mapController?.animateCamera(CameraUpdate.newLatLng(_currentLocation!));
    } catch (e) {
      print('Error getting current location: $e');
    }
  }
  void _addCurrentLocationMarker() {
    if (_currentLocation != null && _currentLocationIcon != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: _currentLocation!,
          icon: _currentLocationIcon!,
        ),
      );
    }
  }
  String decodeChineseCharacters(String input) {
    try {
      return utf8.decode(input.codeUnits);
    } catch (e) {
      print('Error decoding: $e');
      return input;
    }
  }

  bool hasRemainingFood(Map<String, dynamic> post) {
  // 檢查食物數量
    int foodNum = post['food_num'] ?? 0;
    int takedQuantity = post['taked_quantity'] ?? 0;

    // 如果食物數量不足，直接返回 false
    if (foodNum - takedQuantity <= 0) {
      return false;
    }
    print(DateTime.now());
    // 檢查 finish_time 是否已經過期
    if (post.containsKey('finish_time')) {
      DateTime finishTime = DateTime.parse(post['finish_time']); // 將字符串轉為 DateTime 對象
      DateTime now = DateTime.now();

      // 如果 finish_time 已經過期，返回 false
      if (finishTime.isBefore(now)) {
        return false;
      }
      }

      // 如果所有條件都通過，返回 true
      return true;
  }

  Future<void> _fetchAPIData() async {
  try {
    final response = await http.get(Uri.parse('http://192.168.112.134:8000/api/post/'));
    
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<dynamic> posts = jsonData['data'];

      setState(() {
        // 清空 markers
        _markers.clear();
        
        // 重新添加 API 取回的 markers
        _markers.addAll(posts.where((post) => hasRemainingFood(post)).map((post) {
          final double latitude = double.parse(post['latitude']);
          final double longitude = double.parse(post['longitude']);
          final String decodedAddress = decodeChineseCharacters(post['address'] ?? 'No address provided');
          return Marker(
            markerId: MarkerId(post['post_id']),
            position: LatLng(latitude, longitude),
            infoWindow: InfoWindow(title: utf8.decode(post['user_name'].codeUnits)),
            onTap: () {
              setState(() {
                _selectedMarkerData = InfoCardData(
                  location: decodedAddress,
                  imageCodes: List<String>.from(post['image_codes'] ?? []),
                  foodKinds: List<String>.from(post['food_kinds'] ?? []),
                  postTime: post['post_time'],
                  finishTime: post['finish_time'],
                  postId: post['post_id'],
                  receiverId: post['user_id'],
                  food_description: post['food_description'],
                  user_name: post['user_name'],
                  userId: userid,
                  numLikes: post['num_likes'] ?? 0,
                  numDislikes: post['num_dislikes'] ?? 0,
                  numInterests: post['num_interests'] ?? 0,
                  foodNum: post['food_num'] ?? 0,
                  takedQuantity: post['taked_quantity'] ?? 0,
                );
              });
            },
          );
        }).toSet());

        // 重新添加 currentLocation marker
        if (_currentLocation != null && _currentLocationIcon != null) {
          _markers.add(
            Marker(
              markerId: const MarkerId('currentLocation'),
              position: _currentLocation!,
              icon: _currentLocationIcon!,
            ),
          );
        }
      });
    } else {
      print('Failed to load data from API: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching API data: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            initialCameraPosition: CameraPosition(
              target: LatLng(25.0330, 121.5654),
              zoom: 13,
            ),
            markers: _markers,
          ),
        ),
        if (_selectedMarkerData != null)
          InfoCard(data: _selectedMarkerData!),
      ],
    );
  }
}




class InfoCard extends StatelessWidget {
  final InfoCardData data;

  InfoCard({required this.data});

  String decodeText(String input) {
    try {
      return utf8.decode(input.codeUnits);
    } catch (e) {
      print('Error decoding text: $e');
      return input;
    }
  }

  Widget _buildImageFromBase64(String base64String) {
    try {
      return Image.memory(
        base64Decode(base64String.split(',').last),
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    } catch (e) {
      print('Error decoding image: $e');
      return Icon(Icons.error);
    }
  }

  String formatPostTime(String postTime) {
    try {
      final DateTime dateTime = DateTime.parse(postTime);
      final Duration difference = DateTime.now().difference(dateTime);
      if (difference.inDays > 0) {
        return '${difference.inDays} 天前';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} 小時前';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} 分鐘前';
      } else {
        return '剛剛';
      }
    } catch (e) {
      print('Error formatting post time: $e');
      return postTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              decodeText(data.location),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (data.imageCodes.length > 0) _buildImageFromBase64(data.imageCodes[0]),
                SizedBox(width: 16),
                if (data.imageCodes.length > 1) _buildImageFromBase64(data.imageCodes[1]),
                Spacer(),
                if (data.foodKinds.length > 0) Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(decodeText(data.foodKinds[0])),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('有興趣人數: ${data.numInterests}'),
                Text('已放置時間: ${formatPostTime(data.postTime)}'),
              ],
            ),
            SizedBox(height: 8),
            Text('剩餘數量: ${data.foodNum - data.takedQuantity}'),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.thumb_up_alt_outlined),
                    SizedBox(width: 4),
                    Text('${data.numLikes}'),
                    SizedBox(width: 16),
                    Icon(Icons.thumb_down_alt_outlined),
                    SizedBox(width: 4),
                    Text('${data.numDislikes}'),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(data: data),
                      ),
                    );
                  },
                  child: Text('更多資訊'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}