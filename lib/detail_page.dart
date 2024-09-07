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
  @override
  void initState() {
    super.initState();
    int interestedCount = widget.data.numInterests;
    int remainingQuantity = widget.data.foodNum - widget.data.takedQuantity;
    String selectedQuantity = '領取 1份';
    String uploadTime = widget.data.postTime;
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

  Future<void> _handleClaim() async {
    int quantity = int.parse(selectedQuantity.split(' ')[1][0]);
    if (quantity <= remainingQuantity) {
      setState(() {
        remainingQuantity -= quantity;
      });

      
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('成功領取 $quantity 份')),
        );
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('領取失敗')),
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
                      onChanged: updateSelectedQuantity,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                      child: Text('我已領取'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF98D6E8),
                        foregroundColor: Colors.black87,
                      ),
                      onPressed: _handleClaim,
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
                Uint8List imageData = base64Decode(widget.imageUrls[index]);

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
  final Function(bool) onInterestChanged;
  final List<String> tags;
  final bool useHorizontalScroll;
  final InfoCardData data;

  ProviderInfo({
    required this.onInterestChanged,
    required this.tags,
    this.useHorizontalScroll = false,
    required this.data,
  });

  @override
  _ProviderInfoState createState() => _ProviderInfoState();
}

class _ProviderInfoState extends State<ProviderInfo> {
  
  bool isInterested = false;
  int likes = 0;
  int dislikes = 0;
  bool? userRating;

  final List<Color> tagColors = [
    const Color.fromARGB(255, 202, 209, 213),
  ];

  void _handleRating(bool isLike) {
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
              label: Text(tag),
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
          onTap: () {
            setState(() {
              isInterested = !isInterested;
            });
            widget.onInterestChanged(isInterested);
          },
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
          onPressed: () => _handleRating(isLike),
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
  LocationInfo({required this.data});
  

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
          _buildRow('剩餘數量:',  Text((data.foodNum - data.takedQuantity).toString())),
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
