import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Rest extends StatefulWidget{
  const Rest({super.key});

  @override
  _RestState createState()=>_RestState();
}

class _RestState extends State<Rest>{
  List<double> total_month = [0, 760, 820, 910, 320, 690, 832, 234, 456, 728, 901, 802, 210];
  List<double> furniture_month = List<double>.filled(13, 0);
  List<double> bed_month = List<double>.filled(13, 0);
  List<String> taipeiDistricts = [
      '中正',
      '大同',
      '中山',
      '松山',
      '大安',
      '萬華',
      '信義',
      '士林',
      '北投',
      '內湖',
      '南港',
      '文山'
  ];
  List<String> food_label = ['便當','飲料','麵包','蔬果','三明治','零食','其他'];
  @override
  Widget build(BuildContext context){
    return Center(
      child:Column(
        children: [
          _buildTitle('台北市近一年數據資訊'),
          Text("餘食分享趨勢總量", style: TextStyle(fontSize: 20, color:Colors.black)),
          _buildLineChart(),
          Text("餘食分享趨勢總量", style: TextStyle(fontSize: 20, color:Colors.black)),
          _buildBarChart(),
          Text("餘食標籤總計", style: TextStyle(fontSize: 20, color:Colors.black)),
          _buildColumnChart(),
        ],
      )
    );
      
  }

  Widget _buildTitle(String title) {
    return Container(
      padding: EdgeInsets.all(16),
      alignment: Alignment.center,
      child: Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF738995))),
    );
  }

  Widget _buildLineChart() {
    // Implement line chart using fl_chart
    return Container(
      height: 200,
      width: 361,
      padding: EdgeInsets.all(16),
      child: LineChart(
        // LineChartData goes here
        LineChartData(
          gridData: FlGridData(
            drawVerticalLine: false,
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    value.toInt().toString(), // 顯示 X 軸標題
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                );
              },
            )),
            topTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
                ),
              ),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
              show: true,
              border: Border(
                bottom: BorderSide(color: Colors.black, width: 1),
              )
          ), 
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(1, total_month[1]),
                FlSpot(2, total_month[2]),
                FlSpot(3, total_month[3]),
                FlSpot(4, total_month[4]),
                FlSpot(5, total_month[5]),
                FlSpot(6, total_month[6]),
                FlSpot(7, total_month[7]),
                FlSpot(8, total_month[8]),
                FlSpot(9, total_month[9]),
                FlSpot(10, total_month[10]),
                FlSpot(11, total_month[11]),
                FlSpot(12, total_month[12]),
              ],
              isCurved: false, // 曲線
              color: Color(0xFF5AB4C5), // 線條顏色
              barWidth: 4, // 線條寬度
              belowBarData: BarAreaData(
                show: false, // 顯示線條下方填充區域
                color: Colors.blue.withOpacity(0.3),
              ),
            ),
          ],
          minY: 0,
          maxY: 1500,
        )
      )
    );
  }

  Widget _buildBarChart() {
    // Implement bar chart using fl_chart
    return Container(
      width:361,
      height: 200,
      padding: EdgeInsets.all(16),
      child: BarChart(
              BarChartData(
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final int index = value.toInt();
                        if (index >= 0 && index < taipeiDistricts.length) {
                          return Text(
                            taipeiDistricts[index],
                            style: TextStyle(
                              fontSize: 12,
                            )
                          );
                        }
                      return const SizedBox.shrink(); // Return an empty widget if out of range
                      },
                    ),
                  ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false), // Remove top axis
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false), // Remove right axis
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40, interval: 20), // Keep left axis if needed
                ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border(
                bottom: BorderSide(color: Colors.black, width: 1),
              )
            ),
            barGroups: List.generate(taipeiDistricts.length, (index) {
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: (index + 1) * 10.0, // Dummy data for example
                    color: Color(0xFF71C5D5),
                  ),
                ],
              );
            }),
          ),
        ),
    );
  }

  Widget _buildColumnChart() {
    // Implement column chart using fl_chart
    return Container(
      height: 200,
      width: 361,
      padding: EdgeInsets.all(16),
      child: BarChart(
              BarChartData(
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final int index = value.toInt();
                        if (index >= 0 && index < food_label.length) {
                          return Text(
                            food_label[index],
                            style: TextStyle(
                              fontSize: 12,
                            )
                          );
                        }
                      return const SizedBox.shrink(); // Return an empty widget if out of range
                      },
                    ),
                  ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false), // Remove top axis
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false), // Remove right axis
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40, interval: 300), // Keep left axis if needed
                ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border(
                bottom: BorderSide(color: Colors.black, width: 1),
              )
            ),
            barGroups: List.generate(food_label.length, (index) {
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: (index + 30) * 20 % 1000, // Dummy data for example
                    color: Color(0xFF71C5D5),
                  ),
                ],
              );
            }),
          ),
        ),
    );
  }
}