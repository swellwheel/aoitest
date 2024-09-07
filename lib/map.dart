import 'package:flutter/material.dart';
import "global.dart" as global;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import "detail_page.dart";
import 'info_card_data.dart';

String userid = global.user_id;

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  InfoCardData? _selectedMarkerData;

  @override
  void initState() {
    super.initState();
    _fetchAPIData();
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
    int foodNum = post['food_num'] ?? 0;
    int takedQuantity = post['taked_quantity'] ?? 0;
    return foodNum - takedQuantity > 0;
  }

  Future<void> _fetchAPIData() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.112.134:8000/api/post/'));
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> posts = jsonData['data'];

        setState(() {
          _markers = posts.where((post) => hasRemainingFood(post)).map((post) {
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
          }).toSet();
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

// class DetailPage1 extends StatelessWidget {
//   final InfoCardData data;

//   DetailPage({required this.data});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('詳細資訊'),
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               '位置: ${data.location}',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 16),
//             Text('食物種類: ${data.foodKinds.join(", ")}'),
//             SizedBox(height: 8),
//             Text('剩餘數量: ${data.foodNum - data.takedQuantity}'),
//             SizedBox(height: 8),
//             Text('發布時間: ${data.postTime}'),
//             SizedBox(height: 8),
//             Text('有興趣人數: ${data.numInterests}'),
//             SizedBox(height: 8),
//             Text('喜歡: ${data.numLikes}'),
//             SizedBox(height: 8),
//             Text('不喜歡: ${data.numDislikes}'),
//             SizedBox(height: 16),
//             Text('圖片:'),
//             SizedBox(height: 8),
//             ...data.imageCodes.map((imageCode) => Padding(
//               padding: EdgeInsets.only(bottom: 8),
//               child: Image.memory(
//                 base64Decode(imageCode.split(',').last),
//                 fit: BoxFit.cover,
//                 width: double.infinity,
//                 height: 200,
//               ),
//             )).toList(),
//           ],
//         ),
//       ),
//     );
//   }
// }