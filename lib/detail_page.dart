import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'info_card_data.dart';
import "global.dart" as global;
import 'dart:typed_data'; // 需要這個來使用 Uint8List
import 'package:intl/intl.dart';
String userid_detail = global.user_id;

class User {
  final String username;
  final String password;

  User({required this.username, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}

class Post {
  final String title;
  final String content;

  Post({required this.title, required this.content});

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
    };
  }
}

class LikeRequest {
  final String likerId;
  final String receiverId;
  final bool isLike;

  LikeRequest({required this.likerId, required this.receiverId, required this.isLike});

  Map<String, dynamic> toJson() {
    return {
      'liker_id': likerId,
      'receiver_id': receiverId,
      'like_or_dislike': isLike ? '1' : '0',
    };
  }
}

class InterestRequest {
  final String userId;
  final String postId;
  final double longitude;
  final double latitude;

  InterestRequest({
    required this.userId,
    required this.postId,
    required this.longitude,
    required this.latitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'post_id': postId,
      'longitude': longitude.toString(),
      'latitude': latitude.toString(),
    };
  }
}

class TakeRequest {
  final String userId;
  final String postId;
  final int quantity;

  TakeRequest({required this.userId, required this.postId, required this.quantity});

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'post_id': postId,
      'quantity': quantity.toString(),
    };
  }
}

class EmptyReport {
  final String postId;

  EmptyReport({required this.postId});

  Map<String, dynamic> toJson() {
    return {
      'post_id': postId,
    };
  }
}


class DetailPage extends StatefulWidget {
  final InfoCardData data;

  DetailPage({required this.data});

  @override
  _DetailPageState createState() => _DetailPageState();

}

class _DetailPageState extends State<DetailPage> {
  int interestedCount = 0;
  int remainingQuantity = 0;
  String selectedQuantity = '領取 1份';
  String uploadTime = '';
  bool hasClaimed = false;
  bool isInterested = false; // 新增興趣狀態
  bool? userRating; // 用於儲存按讚或不喜歡的狀態

  @override
  void initState() {
    super.initState();
    interestedCount = widget.data.numInterests;
    remainingQuantity = widget.data.foodNum - widget.data.takedQuantity;
    selectedQuantity = '領取 1份';
    uploadTime = widget.data.postTime;
    _checkClaimStatus();
    _checkInterestStatus();
    _checkLikeDislikeStatus();
  }
    // 檢查是否已經有興趣
  Future<void> _checkInterestStatus() async {
    try {
      final interestResponse = await http.get(
        Uri.parse('http://192.168.112.134:8000/api/interest/${userid_detail}/${widget.data.postId}/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (interestResponse.statusCode == 200) {
        final interestResponseBody = jsonDecode(interestResponse.body);

        setState(() {
          isInterested = interestResponseBody['bool'] == true;
        });
      } else {
        throw Exception('Failed to check interest status');
      }
    } catch (e) {
      print('Error checking interest status: $e');
    }
  }

  // 檢查是否有按讚或不喜歡
  Future<void> _checkLikeDislikeStatus() async {
    try {
      final likeResponse = await http.get(
        Uri.parse('http://192.168.112.134:8000/api/like/${userid_detail}/${widget.data.userId}/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (likeResponse.statusCode == 200) {
        final likeResponseBody = jsonDecode(likeResponse.body);

        setState(() {
          userRating = likeResponseBody['like_or_dislike'] == true
              ? true
              : likeResponseBody['like_or_dislike'] == false
                  ? false
                  : null;
        });
      } else {
        throw Exception('Failed to check like status');
      }
    } catch (e) {
      print('Error checking like status: $e');
    }
  }
  void updateInterestedCount(bool isInterested) {
    setState(() {
      interestedCount += isInterested ? 1 : -1;
    });
  }

  void updateSelectedQuantity(String? newValue) {
    if (newValue != null) {
      setState(() {
        selectedQuantity = newValue;
      });
    }
  }
  Future<void> _checkClaimStatus() async {
    try {
      final checkResponse = await http.get(
        Uri.parse('http://192.168.112.134:8000/api/take/${userid_detail}/${widget.data.postId}/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (checkResponse.statusCode == 200) {
        final checkResponseBody = jsonDecode(checkResponse.body);

        // 如果返回 true，表示已經領取過
        if (checkResponseBody['bool'] == true) {
          setState(() {
            hasClaimed = true;
          });
        }
      } else {
        throw Exception('Failed to check claim status');
      }
    } catch (e) {
      print('Error checking claim status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('檢查領取狀態失敗: $e')),
      );
    }
  }
  Future<void> _handleClaim() async {
    int quantity = int.parse(selectedQuantity.split(' ')[1][0]);
    print('領取數量: $quantity');
    print('剩餘數量: $remainingQuantity');
    if (quantity <= remainingQuantity) {
      try {
        final postResponse = await http.post(
          Uri.parse('http://192.168.112.134:8000/api/take/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'user_id': userid_detail,
            'post_id': widget.data.postId,
            'quantity': quantity.toString(),
          }),
        );

        if (postResponse.statusCode == 200) {
          final postResponseBody = jsonDecode(postResponse.body);

          // 更新剩餘數量並顯示成功訊息
          setState(() {
            remainingQuantity -= quantity;
            hasClaimed = true; // 設定已領取
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('成功領取 $quantity 份')),
          );
        } else {
          throw Exception('Failed to claim');
        }
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('領取失敗: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('剩餘數量不足')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> demoImages = widget.data.imageCodes;
    return Scaffold(
      appBar: AppBar(title: Text('詳細資訊')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ImageCarousel(imageUrls: demoImages),
            ProviderInfo(
            tags: widget.data.foodKinds, // 假設 foodKinds 是一個類似 tags 的列表
            onInterestChanged: (bool isInterested) {
              updateInterestedCount(isInterested);
            },
            data: widget.data,  // 傳遞 data
            ),
            LocationInfo(
              data: widget.data,
              remainingQuantity: remainingQuantity,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: DropdownButton<String>(
                      value: selectedQuantity,
                      items: <String>['領取 1份', '領取 2份', '領取 3份']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: hasClaimed ? null : updateSelectedQuantity,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                      child: Text(hasClaimed ? '已領取' : '我要領取'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hasClaimed ? Colors.grey : Color(0xFF98D6E8),
                        foregroundColor: Colors.black87,
                      ),
                      onPressed: hasClaimed ? null : _handleClaim,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;

  ImageCarousel({required this.imageUrls});

  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _currentPage = 0;
  late PageController _pageController;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1, // 使容器為正方形
      child: Container(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.imageUrls.length,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemBuilder: (context, index) {
                // 解碼 base64 編碼的圖片數據
                
                try {
                  // 如果 Base64 字符串有前綴 "data:image/png;base64,", 切割後使用編碼部分
                  String base64String = widget.imageUrls[index].contains(',')
                      ? widget.imageUrls[index].split(',').last
                      : widget.imageUrls[index];

                  Uint8List imageData = base64Decode(base64String);

                  return Image.memory(
                    imageData,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.error, color: Colors.red),
                      );
                    },
                  );
                } catch (e) {
                  print('Error decoding Base64 image: $e');
                  return Container(
                    color: Colors.grey[200],
                    child: Icon(Icons.error, color: Colors.red),
                  );
                }
              },
            ),
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.imageUrls.map((url) {
                  int index = widget.imageUrls.indexOf(url);
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    margin: EdgeInsets.symmetric(horizontal: 2.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? Colors.blue
                          : Colors.grey.withOpacity(0.5),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProviderInfo extends StatefulWidget {
  final dynamic data;
  final List<String> tags;
  final bool useHorizontalScroll;
  final Function(bool) onInterestChanged;

  const ProviderInfo({
    Key? key,
    required this.data,
    required this.tags,
    this.useHorizontalScroll = false,
    required this.onInterestChanged,
  }) : super(key: key);

  @override
  _ProviderInfoState createState() => _ProviderInfoState();
}

class _ProviderInfoState extends State<ProviderInfo> {
  
  bool isInterested = false;
  bool? userRating;
  int likes = 0;
  int dislikes = 0;

  final List<Color> tagColors = [
    const Color.fromARGB(255, 202, 209, 213),
  ];

  Future<void> _handleLikeDislike(bool isLike) async {
    // 保存原始狀態，以便在需要時恢復
    final originalUserRating = userRating;
    final originalLikes = likes;
    final originalDislikes = dislikes;

    // 更新 UI
    setState(() {
      if (userRating == isLike) {
        // 取消當前選擇
        userRating = null;
        isLike ? likes-- : dislikes--;
      } else {
        // 切換選擇
        if (userRating != null) {
          userRating! ? likes-- : dislikes--;
        }
        userRating = isLike;
        isLike ? likes++ : dislikes++;
      }
    });

    // 調用 API
    final url = Uri.parse('http://192.168.112.134:8000/api/like/');
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'liker_id': userid_detail,
          'receiver_id': widget.data.userId,
          'like_or_dislike': isLike ? "0" : "1",
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('API調用失敗：${response.statusCode}');
      }
    } catch (e) {
      // 錯誤處理
      print('發生異常：$e');
      // 恢復原始狀態
      setState(() {
        userRating = originalUserRating;
        likes = originalLikes;
        dislikes = originalDislikes;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('操作失敗，請稍後再試')),
      );
    }
  }

  Future<void> _handleInteraction(bool? isLike) async {
    if (isLike == null) {
      await _handleInterest();
    } else {
      await _handleLike(isLike);
    }
  }
  Future<void> _handleInterest() async {
    final url = Uri.parse('http://192.168.112.134:8000/api/interest/');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'user_id': userid_detail,
        'post_id': widget.data.postId,
        'longitude': widget.data.location,
        'latitude': widget.data.location,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        isInterested = !isInterested;
        widget.onInterestChanged(isInterested);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('無法更新興趣狀態，請稍後再試')),
      );
    }
  }

  Future<void> _handleLike(bool isLike) async {
    // 保存原始狀態，以便在發生錯誤時恢復
    final originalUserRating = userRating;
    final originalLikes = likes;
    final originalDislikes = dislikes;

    // 立即更新 UI 以提供即時反饋
    setState(() {
      if (userRating == isLike) {
        userRating = null;
        isLike ? likes-- : dislikes--;
      } else {
        if (userRating != null) {
          userRating! ? likes-- : dislikes--;
        }
        userRating = isLike;
        isLike ? likes++ : dislikes++;
      }
    });

    final url = Uri.parse('http://192.168.112.134:8000/api/like/');
    try {
      print('Sending request to: $url');
      print('Request body: ${jsonEncode(<String, dynamic>{
        'liker_id': userid_detail,
        'receiver_id': widget.data.userId,
        'like_or_dislike': isLike,
      })}');

      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'liker_id': userid_detail,
          'receiver_id': widget.data.userId,
          'like_or_dislike': isLike,
        }),
      );

      print('API Response Status Code: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('API調用失敗：${widget.data.userId}');
      }
    } catch (e) {
      print('發生異常：$e');
      // 恢復原始狀態
      setState(() {
        userRating = originalUserRating;
        likes = originalLikes;
        dislikes = originalDislikes;
      });

      String errorMessage;
      if (e.toString().contains('SocketException')) {
        errorMessage = '網絡連接錯誤，請檢查您的網絡連接';
      } else if (e.toString().contains('500')) {
        errorMessage = '服務器內部錯誤，請稍後再試';
      } else {
        errorMessage = '操作失敗，請稍後再試';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: Duration(seconds: 5),
          action: SnackBarAction(
            label: '重試',
            onPressed: () => _handleLike(isLike),
          ),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.useHorizontalScroll
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: _buildProviderInfoContent(),
                )
              : _buildProviderInfoContent(),
          SizedBox(height: 8),
          _buildInteractionRow(),
        ],
      ),
    );
  }

  Widget _buildProviderInfoContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '提供者: ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(utf8.decode(widget.data.user_name.codeUnits)),
          ],
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: widget.tags.asMap().entries.map((entry) {
            int idx = entry.key;
            String tag = entry.value;
            return Chip(
              label: Text(utf8.decode(tag.codeUnits)),
              backgroundColor: tagColors[idx % tagColors.length],
              labelStyle: TextStyle(fontSize: 12, color: const Color.fromARGB(255, 255, 255, 255)),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInteractionRow() {
    return Row(
      children: [
        InkWell(
          onTap: () => _handleInteraction(null),
          child: Row(
            children: [
              Icon(
                isInterested ? Icons.favorite : Icons.favorite_border,
                color: isInterested ? Colors.red : Colors.grey,
              ),
              SizedBox(width: 4),
              Text(
                '我有興趣',
                style: TextStyle(
                  color: isInterested ? Colors.red : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Spacer(),
        _buildRatingButton(true),
        SizedBox(width: 16),
        _buildRatingButton(false),
      ],
    );
  }

  Widget _buildRatingButton(bool isLike) {
    final icon = isLike ? Icons.thumb_up : Icons.thumb_down;
    final color = isLike ? Colors.blue : Colors.red;
    final count = isLike ? likes : dislikes;
    final isSelected = userRating == isLike;

    return Row(
      children: [
        IconButton(
          icon: Icon(icon, color: isSelected ? color : Colors.grey),
          onPressed: () => _handleInteraction(isLike),
        ),
        Text(
          '$count',
          style: TextStyle(
            color: isSelected ? color : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class LocationInfo extends StatelessWidget {

  final InfoCardData data;
  final int remainingQuantity;
  LocationInfo({required this.data, required this.remainingQuantity});
  

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRow('位置資訊:', Text(data.location)),
          _buildRow('感興趣人數: ', Text(data.numInterests.toString())),
          _buildRow('上架時間:', Text(DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(data.postTime)).toString())),
          _buildRow('結束時間:', Text(DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(data.finishTime)).toString())),
          _buildRow('剩餘數量:',  Text(remainingQuantity.toString())),
          _buildRow('其他說明:',  Text(utf8.decode(data.food_description.codeUnits))),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, Widget valueWidget) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: valueWidget,
          ),
        ],
      ),
    );
  }


  Widget _buildInterestRow(String distance, String interestCount) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      color: Colors.grey[200],
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Text(
                distance,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
          ),
          Container(
            width: 1,
            height: 24,
            color: Colors.grey[400],
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Text(
                interestCount,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MoreInfoButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: ElevatedButton(
        child: Text(
          '更多資訊',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF98D6E8),
          foregroundColor: Colors.black87,
          minimumSize: Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        onPressed: () {
          print('更多資訊按鈕被點擊');
        },
      ),
    );
  }
}
