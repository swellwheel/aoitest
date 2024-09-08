import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'rest.dart';
import 'user.dart';

class Data extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnalysisPage(),
    );
  }
}

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  _AnalysisPageState createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  int _currentIndex = 0;
  final Color buttonColor = const Color.fromARGB(255, 55, 172, 172);

  final pages = [Rest(), User()];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 320.0,
              height: 40.0,
              decoration: BoxDecoration(
                border: Border.all(
                  color: buttonColor, // 设置边框颜色
                  width: 1, // 设置边框宽度
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTextButton(
                    text: '餘食數據統計',
                    isActive: _currentIndex == 0,
                    onPressed: () => _press(0),
                  ),
                  _buildTextButton(
                    text: '使用者英雄榜',
                    isActive: _currentIndex == 1,
                    onPressed: () => _press(1),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: pages[_currentIndex], // 切换页面
          ),
        ],
      ),
    );
  }

  Widget _buildTextButton({
    required String text,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.blue : Colors.black,
          ),
        ),
      ),
      style: ButtonStyle(
        fixedSize: MaterialStateProperty.all(const Size(159, 20)),
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return buttonColor; // 按钮被点击时的背景色
            }
            return Colors.white; // 按钮的默认背景色
          },
        ),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // 移除圆角，使按钮为矩形
          ),
        ),
      ),
    );
  }

  void _press(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
