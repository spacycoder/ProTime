import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pro_time/model/project.dart';
import 'package:pro_time/pages/project/widgets/date_range_text.dart';
import 'package:pro_time/pages/project/widgets/stepper_button.dart';

class HourBarChart extends StatefulWidget {
  HourBarChart(this.project);

  final Project project;

  @override
  _HourBarChartState createState() => _HourBarChartState();
}

class _HourBarChartState extends State<HourBarChart> {
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  double maxHours = 0.0;

  @override
  void initState() {
    setWeek();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StepperButton(
              onLeftTap: () => setState(() {
                shiftWeekLeft(true);
              }),
              onRightTap: DateTime.now().isAfter(endDate)
                  ? () => setState(() {
                        shiftWeekLeft(false);
                      })
                  : null,
            ),
            DateRangeText(startDate: startDate, endDate: endDate)
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        Expanded(
          child: BarChart(
            mainBarData(getBarChartData(getWeekActivities())),
          ),
        ),
      ],
    );
  }

  BarChartData mainBarData(List<BarChartGroupData> barChartData) {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: widget.project.mainColor,
          getTooltipItem: (BarChartGroupData groupData, int groupIndex,
              BarChartRodData rodData, int rodIndex) {
            List<String> days = [
              'Monday',
              'Tuesday',
              'Wednesday',
              'Thursday',
              'Friday',
              'Saturday',
              'Sunday'
            ];
            return BarTooltipItem(
              "${days[groupIndex]} \n ${rodData.y}H",
              TextStyle(
                color: widget.project.textColor,
              ),
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
            showTitles: true,
            textStyle: TextStyle(
              color: Theme.of(context).textTheme.display1.color,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            margin: 16,
            getTitles: (double value) {
              switch (value.toInt()) {
                case 0:
                  return 'M';
                case 1:
                  return 'T';
                case 2:
                  return 'W';
                case 3:
                  return 'T';
                case 4:
                  return 'F';
                case 5:
                  return 'S';
                case 6:
                  return 'S';
                default:
                  return '';
              }
            }),
        leftTitles: const SideTitles(
          showTitles: false,
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: barChartData,
    );
  }

  List<BarChartGroupData> getBarChartData(List<Duration> days) {
    int i = 0;
    return days.map((h) {
      final hours = h.inSeconds / 3600;
      if (hours > maxHours) {
        maxHours = hours;
      }
      return makeGroupData(i++, roundDecimal(hours, 1));
    }).toList();
  }

  BarChartGroupData makeGroupData(int x, double y) {
    return BarChartGroupData(x: x, barRods: [
      BarChartRodData(
        y: y,
        color: Theme.of(context).textTheme.headline.color,
        width: 22,
        isRound: true,
        backDrawRodData: BackgroundBarChartRodData(
          show: true,
          y: maxHours,
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
    ]);
  }

  double roundDecimal(double number, int decimals) =>
      double.parse(number.toStringAsFixed(decimals));

  List<DateTime> weekDates = [];

  List<Duration> getWeekActivities() {
    final List<Duration> hours = [];
    for (int i = 0; i < 7; i++) {
      hours.add(Duration(seconds: 0));
      for (Activity activity in widget.project.activities) {
        if (isSameDay(weekDates[i], activity.getFirstStarted())) {
          hours[i] = hours[i] + activity.getDuration();
        }
      }
    }
    return hours;
  }

  setWeek() {
    DateTime today = DateTime.now();
    weekDates.clear();
    for (int day = 0; day < 7; day++) {
      final days = today.weekday - day - 1;
      weekDates.add(DateTime.now().subtract(Duration(days: days)));
    }
    startDate = weekDates[0];
    endDate = weekDates[6];
  }

  shiftWeekLeft(bool shiftLeft) {
    final oldStartDay = startDate;
    weekDates.clear();
    if (shiftLeft) {
      for (int day = 7; day > 0; day--) {
        weekDates.add(oldStartDay.subtract(Duration(days: day)));
      }
    } else {
      for (int day = 0; day < 7; day++) {
        weekDates.add(oldStartDay.add(Duration(days: 7 + day)));
      }
    }
    startDate = weekDates[0];
    endDate = weekDates[6];
  }

  bool isSameDay(DateTime one, DateTime two) {
    return (one.day == two.day &&
        one.month == two.month &&
        one.year == two.year);
  }
}