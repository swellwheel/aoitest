import 'package:flutter/material.dart';
class SummitPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 第一個區塊
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFE0F7FA), // 背景顏色
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.grey, // 灰色邊框
                    width: 2.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Image.asset(
                      'assets/second1.png', // 您提供的圖標，替換成正確路徑
                      width: 80,
                      height: 80,
                    ),
                    Text(
                      '掠食者',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16), // 區塊之間的間隔

            // 第二個區
          ],
        ),
      ),
    );
  }
}