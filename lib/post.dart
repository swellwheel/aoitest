import 'dart:convert';
import 'package:http/http.dart' as http;

/*final selectedData = {
      'user_id': provider,
      'longitude': currentLocation,
      'latitude':,
      '': currentDistrict,
      'food_description': description,
      'food_num': _quantity,
      'finish_time': '$selectedValue $selected_min',
      'food_kinds': tags,
      'image_codes': pictures,
    };*/

Future<void> sendPostRequest(dynamic Data) async {
  final url = Uri.parse('http://192.168.112.134:8000/api/post/'); // 替换为你的 URL
  final headers = {"Content-Type": "application/json"};
  final body = jsonEncode({
    'user_id': Data['user_id'],
    'longitude': Data['longitude'],
    'latitude': Data['latitude'],
    'address': Data['address'],
    'food_description': Data['food_description'],
    'food_num': Data['food_num'],
    'finish_time': Data['finish_time'],
    'food_kinds': Data['food_kinds'],
    'image_codes': Data['image_codes'],
  });

  try {
    print('body: $body');
    
    final response = await http.post(url, headers: headers, body: body);
    
    if (response.statusCode == 200) {
      // 处理成功响应
      print('Response: ${response.body}');
    } else {
      // 处理错误
      print('Error: ${response.statusCode}');
    }
  } catch (e) {
    // 处理异常
    print('Exception: $e');
  }
  
}
