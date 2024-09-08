import 'package:flutter/material.dart';


class User extends StatefulWidget{
  const User({super.key});
  @override
  _UserState createState()=>_UserState();
}
class _UserState extends State<User> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Center(
              child: Text(
                '台北市近一年數據資訊',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16),

            // Ranking Section
            Text(
              '提供者分享量排名',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            // Trophy and Ranking
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Icon(Icons.emoji_events, color: Colors.grey, size: 50),
                    Text('胡金龍'),
                    Text('200'),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.emoji_events, color: Colors.yellow, size: 50),
                    Text('張志豪'),
                    Text('212'),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.emoji_events, color: Colors.orange, size: 50),
                    Text('陳怡君'),
                    Text('188'),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),

            // Bar Chart for 分享量排名
            BarChartWidget(
              data: [
                ChartData('孫悟空', 80),
                ChartData('牛魔王', 70),
                ChartData('紅孩兒', 60),
                ChartData('拉不拉多', 50),
                ChartData('趙子龍', 40),
                ChartData('長頸鹿', 30),
              ],
              title: '分享量排名',
            ),

            SizedBox(height: 16),
            Text(
              '提供者評價排名',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            // Trophy and Ranking for 評價排名
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Icon(Icons.emoji_events, color: Colors.grey, size: 50),
                    Text('黑客松'),
                    Text('200'),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.emoji_events, color: Colors.yellow, size: 50),
                    Text('城市通'),
                    Text('212'),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.emoji_events, color: Colors.orange, size: 50),
                    Text('台北通'),
                    Text('188'),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),

            // Bar Chart for 評價排名
            BarChartWidget(
              data: [
                ChartData('黑客松', 95),
                ChartData('城市通', 88),
                ChartData('台北通', 82),
                ChartData('好厝邊', 75),
                ChartData('愛心棧', 70),
                ChartData('食物銀行', 65),
              ],
              title: '評價排名',
            ),
          ],
        ),
      );
    
  }
}

class ChartData {
  final String label;
  final int value;

  ChartData(this.label, this.value);
}

class BarChartWidget extends StatelessWidget {
  final List<ChartData> data;
  final String title;

  BarChartWidget({required this.data, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  color: Colors.blue,
                ),
                SizedBox(width: 5),
                Text('單位份'),
              ],
            ),
          ],
        ),
        SizedBox(height: 10),
        ...data.map((item) => _buildBarRow(item.label, item.value)).toList(),
      ],
    );
  }

  Widget _buildBarRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label),
          ),
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: value / 100,
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Text('$value'),
        ],
      ),
    );
  }
}