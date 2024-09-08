import 'dart:convert';
import 'package:flutter/material.dart';
import 'location.dart';
import 'package:geolocator/geolocator.dart';
import 'post.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'image.dart';
class SummitPage  extends StatefulWidget {
  const SummitPage ({super.key});
  @override
  _SummitPageState  createState() => _SummitPageState ();
}

class _SummitPageState  extends State<SummitPage> {
  List<bool> flag = List<bool>.filled(3, false);
  List<dynamic> pic = List<dynamic>.filled(3, Center(
                        child: Container(
                          width: 60.0, // 半径的两倍
                          height: 60.0, // 半径的两倍
                          decoration: BoxDecoration(
                            color: Colors.white, // 背景颜色
                            shape: BoxShape.circle, // 圆形
                          ),
                          child: Icon(Icons.add, size: 24, color: Colors.black),
                        ),
                      
                    ));
  String location = '尚未取得定位';
  int _quantity = 1;
  double longitude = 0;
  double latitude = 0;
  String selectedValue = '18時';
  String selected_min = '00分';
  String provider = 'a3ce941d-e3a6-4702-9e0c-5d735a5a0550';
  String currentLocation = '台北市';
  String currentDistrict = '中正區';
  List<String> pictures = [];//不能為空
  String description = '';
  List<String> tags = ['蔬菜水果', '']; // 预设两个标签
  
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(() {
      setState(() {
        description = _descriptionController.text;
      });
    });
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min, // 使 Column 尽可能小
            children: [
              Text('確定要上傳嗎？'),
              // 其他内容
            ],
          ),
          actions: <Widget>[
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    child: Text('取消'),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey[200], // 设置背景颜色
                      foregroundColor: Colors.black, // 设置文字颜色
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // 关闭对话框
                    },
                  ),
                ),
                SizedBox(width: 8), // 按钮之间的间隔
                Expanded(
                  child: TextButton(
                    child: Text('上架'),
                    style: TextButton.styleFrom(
                      backgroundColor: Color(0xFF5AB4C5),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      // 执行上架操作
                      _handleSubmit();
                      Navigator.of(context).pop(); // 关闭对话框
                      // 可以在这里添加其他操作，比如提交表单等
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }


  void _handleSubmit() {
    // 获取所有选择的信息
    print('$currentLocation$currentDistrict${_addressController.text}');
    final selectedData = {
      'user_id': provider,
      'longitude': longitude.toString(),
      'latitude': latitude.toString(),
      'address': '$currentLocation$currentDistrict${_addressController.text}',
      'food_description': description,
      'food_num': _quantity.toString(),
      'finish_time': formatter.format(DateTime(2024, 9, 8, int.parse(selectedValue.substring(0,2)), int.parse(selected_min.substring(0,2)))),
      'food_kinds': tags,
      'image_codes': pictures,
    };

    // 打印所有选择的信息
    //print('Selected Data: $selectedData');
    sendPostRequest(selectedData);
    Navigator.pop(context);
    // 你可以在这里处理提交逻辑，比如将数据上传到服务器
    // 或者显示一个确认对话框等
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Handle back button press
          },
        ),
        title: Text('提供者登錄表單'),
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              // Handle close button press
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Row(
              children: [
                Text('當前位置:', style: TextStyle(fontSize: 16)),
                ElevatedButton(
                onPressed: () async {
                  List<double> coordinates = [0, 0];
                  await getCurrentLocation(coordinates);
                  setState(() {
                    longitude = coordinates[0];
                    latitude = coordinates[1];
                  });
                },

                child: Text('取得目前位置'),
                ),
              ],),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFE3E7E9),
                    ),
                    items: [DropdownMenuItem(child: Text('台北市'), value: '台北市'),],
                    onChanged: (value) {
                      setState(() {
                        currentLocation = value!;
                      });
                    },
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFDBF1F5),
                    ),
                    items: [
                      DropdownMenuItem(child: Text('中正區'), value: '中正區'),
                      DropdownMenuItem(child: Text('大同區'), value: '大同區'),
                      DropdownMenuItem(child: Text('中山區'), value: '中山區'),
                      DropdownMenuItem(child: Text('松山區'), value: '松山區'),
                      DropdownMenuItem(child: Text('大安區'), value: '大安區'),
                      DropdownMenuItem(child: Text('萬華區'), value: '萬華區'),
                      DropdownMenuItem(child: Text('信義區'), value: '信義區'),
                      DropdownMenuItem(child: Text('士林區'), value: '士林區'),
                      DropdownMenuItem(child: Text('北投區'), value: '北投區'),
                      DropdownMenuItem(child: Text('內湖區'), value: '內湖區'),
                      DropdownMenuItem(child: Text('南港區'), value: '南港區'),
                      DropdownMenuItem(child: Text('文山區'), value: '文山區'),
                    ],
                    onChanged: (value) {
                      setState(() {
                        currentDistrict = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFFDBF1F5),
                hintText: '請輸入詳細地址',
              ),
            ),
            SizedBox(height: 16),
            Text('其他說明:', style: TextStyle(fontSize: 16)),
            TextFormField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFFD1FFF2),
              ),
              controller: _descriptionController,
            ),
            SizedBox(height: 16),
            Text('照片上傳:', style: TextStyle(fontSize: 16)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (index) => 
                Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () async{
                      String? selectedImage = await pickImage(); // 確保 pickImage 返回的是 base64 字符串
  
                    if (selectedImage != null) {
                      // 如果列表中這個位置沒有初始化，則擴展列表的大小
                      if (pictures.length <= index) {
                        pictures.addAll(List<String>.filled(index - pictures.length + 1, ''));
                      }

                      // 更新圖片數據
                      setState(() {
                        pictures[index] = selectedImage; // 將圖片的 base64 編碼保存到列表
                        flag[index] = true; // 標記圖片已選擇
                        pic[index] = Image.memory(base64Decode(pictures[index])); // 顯示選擇的圖片
                      });

                      print('Container $index tapped');
                    }
                    },
                    child:  Container(
                      width: 100,
                      height: 108,
                      decoration: BoxDecoration(
                        color: Color(0xFFDBF1F5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: pic[index],
                    )
                  ),
                ),
              ),

            ),
            SizedBox(height: 16),
            Text('結束時間:', style: TextStyle(fontSize: 16)),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFEBF7F8), // 背景颜色
                    ),
                    value: selectedValue, // 默认值为 18时
                    items: List.generate(25, (index) {
                      return DropdownMenuItem(
                        child: Text('$index時'), // 显示文本
                        value: '$index時', // 下拉项的值
                      );
                    }),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedValue = newValue!;
                      });
                    },

                  )
                  ,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFEBF7F8), // 背景颜色
                    ),
                    value: '00分', // 默认值为 '00分'
                    items: List.generate(60, (index) {
                      // 格式化分钟为两位数，例如 '00分', '01分' 到 '59分'
                      String minute = index.toString().padLeft(2, '0');
                      return DropdownMenuItem(
                        value: '$minute分',
                        child: Text('$minute分'),
                      );
                    }),
                    onChanged: (String? newValue) {
                      setState(() {
                        selected_min = newValue!;
                      });
                    },
                  )
                ),
              ],
            ),
            SizedBox(height: 16),
            Text('標籤(最多兩個):', style: TextStyle(fontSize: 16)),
            
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField(
                    value: tags[0],
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFEBF7F8),
                    ),
                    items: [
                      DropdownMenuItem(child: Text('便當'), value: '便當'),
                      DropdownMenuItem(child: Text('飲料'), value: '飲料'),
                      DropdownMenuItem(child: Text('麵包'), value: '麵包'),
                      DropdownMenuItem(child: Text('速食'), value: '速食'),
                      DropdownMenuItem(child: Text('麵類'), value: '麵類'),
                      DropdownMenuItem(child: Text('飯類'), value: '飯類'),
                      DropdownMenuItem(child: Text('三明治'), value: '三明治'),
                      DropdownMenuItem(child: Text('蔬菜水果'), value: '蔬菜水果'),
                      DropdownMenuItem(child: Text('零食'), value: '零食'),
                      DropdownMenuItem(child: Text('其他'), value: '其他'),
                    ],
                    onChanged: (value) {
                      setState(() {
                        tags[0] = value!;
                      });
                    },

                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField(
                    value: tags[1],
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFEBF7F8),
                    ),
                    items: [
                      DropdownMenuItem(child: Text(''), value: ''),
                      DropdownMenuItem(child: Text('便當'), value: '便當'),
                      DropdownMenuItem(child: Text('飲料'), value: '飲料'),
                      DropdownMenuItem(child: Text('麵包'), value: '麵包'),
                      DropdownMenuItem(child: Text('速食'), value: '速食'),
                      DropdownMenuItem(child: Text('麵類'), value: '麵類'),
                      DropdownMenuItem(child: Text('飯類'), value: '飯類'),
                      DropdownMenuItem(child: Text('三明治'), value: '三明治'),
                      DropdownMenuItem(child: Text('蔬菜水果'), value: '蔬菜水果'),
                      DropdownMenuItem(child: Text('零食'), value: '零食'),
                      DropdownMenuItem(child: Text('其他'), value: '其他'),
                    ],
                    onChanged: (value) {
                      setState(() {
                        tags[1] = value!;
                      });
                    },

                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2, // 设置 Container 占据的比例
                  child: Container(
                    height: 40,
                    color: Color(0xFFCAD1D5),
                    child: Center(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '提供份數: ', // 固定文本
                              style: TextStyle(fontSize: 16, color: Colors.black), // 固定文本的样式
                            ),
                            TextSpan(
                              text: '$_quantity ', // 变量文本
                              style: TextStyle(fontSize: 16, color: Colors.white), // 变量文本的样式
                            ),
                            TextSpan(
                              text: '份', // 固定文本
                              style: TextStyle(fontSize: 16, color: Colors.white), // 固定文本的样式
                            ),
                          ],
                        ),
                      ),
                    )
                  ),
                ),
                SizedBox(width: 10), // 为组件之间添加间隔
                Expanded(
                  flex: 2, // 设置 CircleAvatar 行占据的比例
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center, // 使 CircleAvatar 居中
                    children: [
                      CircleAvatar(
                        radius: 20, // 圆形的半径
                        backgroundColor: Colors.blueGrey[50], // 背景颜色
                        child: IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if (_quantity > 1) _quantity--;
                            });
                          },
                        ), // 图标
                      ),
                      SizedBox(width: 20), // 圆形图标之间的间隔
                      CircleAvatar(
                        radius: 20, // 圆形的半径
                        backgroundColor: Colors.blueGrey[50], // 背景颜色
                        child: IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              _quantity++;
                            });
                          },
                        ), // 图标
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),
            SizedBox(
              width: 329,
              height: 50,
              child: ElevatedButton(
                child: Text('上架', style: TextStyle(fontSize:16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4AC9D4), // 设置按钮的背景色
                  foregroundColor: Colors.white,     
                  //padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // 设置圆角为零，变为直角
                  ),
                ),
                onPressed: () {
                  // Handle submit
                  _showConfirmationDialog();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 

