import 'package:flutter/material.dart';
import "choose_page.dart";
import "map.dart";
import "summit.dart";
import "analysis.dart";
import "global.dart" as global;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),  // 導入主頁
  
      routes: {
        '/choose': (context) => ChoosePage(), // 第一個頁面
        '/map':(context) => MapPage(),
        "/summit" : (context) => SummitPage(),
        "/analysis" : (context) => AnalysisPage(),
      },);
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String this_user_id = global.user_id;
    return Scaffold(
      body: Center(
        child: Container(
          width: 393,  // 固定寬度
          height: 852, // 固定高度
          color: Colors.grey[200], // 外圍顏色可以用來區分背景
          child: Stack(
            children: [
              Column(
                children: [
                  // 上半部的圖片區域
                  Container(
                    height: 450, // 佔固定大小的一半
                    width: double.infinity,
                    color: Colors.white, // 設定底色為白色
                    child: Image.asset(
                      'assets/first.png', // 替換為您提供的圖像路徑
                      fit: BoxFit.cover, // 圖片會填滿上半部且自動放大縮小
                    ),
                  ),
                  // 下半部的文字和白色背景
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50.0), // 左右各留 50px
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20),
                            Text(
                              '餘食分享服務系統',
                              style: TextStyle(
                                color: Color(0xFF1D1617), // 深色標題顏色
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '餘食分享服務系統是一個致力於減少食物浪費的城市服務系統。這個平台的主要目的是將多餘的食物有效地轉移給有需要的人，從而達到資源再利用和幫助社會弱勢群體的雙重目的。',
                              style: TextStyle(
                                color: Color(0xFF7B6F72), // 描述文字的顏色
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // 右下角的按鈕
              Positioned(
                bottom: 15,
                right: 20,
                child: Container(
                    width: 50,
                    height: 50,
                    child: FloatingActionButton(
                    onPressed: () {
                      // 導航到下一個頁面
                      Navigator.pushNamed(context, '/choose');
                    },
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.arrow_forward, size: 30, color: Colors.white),
                  ),
                ) 
                
              ),
            ],
          ),
        ),
      ),
    );
  }
}
