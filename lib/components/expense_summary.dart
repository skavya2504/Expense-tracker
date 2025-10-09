import 'package:expense_tracker_app/data/expense_data.dart';
import 'package:expense_tracker_app/datetime/date_time_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../bar graph/bar_graph.dart';

class ExpenseSummary extends StatelessWidget{
  final DateTime startofweek;
  const ExpenseSummary({
    super.key,
    required this.startofweek
});

  //calculate max amount in bar graph
  double calculateMax(
      ExpenseData value,
      String sunday,
      String monday,
      String tuesday,
      String wednesday,
      String thursday,
      String friday,
      String saturday,
      ){
        double? max = 100;

        List<double> values = [
          value.calculateDailyExpenseSummary()[sunday] ?? 0,
          value.calculateDailyExpenseSummary()[monday] ?? 0,
          value.calculateDailyExpenseSummary()[tuesday] ?? 0,
          value.calculateDailyExpenseSummary()[wednesday] ?? 0,
          value.calculateDailyExpenseSummary()[thursday] ?? 0,
          value.calculateDailyExpenseSummary()[friday] ?? 0,
          value.calculateDailyExpenseSummary()[saturday] ?? 0,
        ];

        values.sort();
        max=values.last * 1.1;
        return max==0 ? 100 : max;
  }

  // calculate month total
  double calculateMonthTotal(ExpenseData value){
    DateTime today = DateTime.now();
    int monthDays = today.day;
    double monthTotal=0;
    for(int i=0;i<monthDays;i++){
      String thisDay = convertDateTimeToString(today.subtract(Duration(days: i)));
      double amount = value.calculateDailyExpenseSummary()[thisDay] ?? 0;
      monthTotal+=amount;
    }
    return monthTotal;
  }

  //calculate week total
  double calculateWeekTotal(
      ExpenseData value,
      String sunday,
      String monday,
      String tuesday,
      String wednesday,
      String thursday,
      String friday,
      String saturday,
      ){
        List<double> values = [
          value.calculateDailyExpenseSummary()[sunday] ?? 0,
          value.calculateDailyExpenseSummary()[monday] ?? 0,
          value.calculateDailyExpenseSummary()[tuesday] ?? 0,
          value.calculateDailyExpenseSummary()[wednesday] ?? 0,
          value.calculateDailyExpenseSummary()[thursday] ?? 0,
          value.calculateDailyExpenseSummary()[friday] ?? 0,
          value.calculateDailyExpenseSummary()[saturday] ?? 0,
    ];
        double total = 0;
        for(int i=0;i<values.length;i++){
          total+=values[i];
        }
        return total;
  }

  @override
  Widget build(BuildContext context){

    String sunday=convertDateTimeToString(startofweek.add(Duration(days: 0)));
    String monday=convertDateTimeToString(startofweek.add(Duration(days: 1)));
    String tuesday =convertDateTimeToString(startofweek.add(Duration(days: 2)));
    String wednesday =convertDateTimeToString(startofweek.add(Duration(days: 3)));
    String thursday =convertDateTimeToString(startofweek.add(Duration(days: 4)));
    String friday =convertDateTimeToString(startofweek.add(Duration(days: 5)));
    String saturday=convertDateTimeToString(startofweek.add(Duration(days: 6)));

    return Consumer<ExpenseData>(
      builder : (context,value,child) => Column(
        children: [
          // totals
          Padding(
              padding: const EdgeInsets.fromLTRB(25.0,25,25,10),
              child: Row(
                children: [
                  const Text(
                    'Week Total: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.currency_rupee, size: 14,),
                  Text('${calculateWeekTotal(value, sunday, monday, tuesday, wednesday, thursday, friday, saturday)}')
                ],
              ),
          ),
          Padding(
              padding: const EdgeInsets.fromLTRB(25.0,10,25,10),
              child: Row(
                children: [
                  const Text(
                    'Month Total: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.currency_rupee, size: 14,),
                  Text('${calculateMonthTotal(value)}')
                ],
              ),
          ),
          SizedBox(
            height: 210,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0,10,0,0),
              child: MyBarGraph(
                  maxY: calculateMax(value, sunday, monday, tuesday, wednesday, thursday, friday, saturday),
                  sunAmount: value.calculateDailyExpenseSummary()[sunday] ?? 0,
                  monAmount: value.calculateDailyExpenseSummary()[monday] ?? 0,
                  tueAmount: value.calculateDailyExpenseSummary()[tuesday] ?? 0,
                  wedAmount: value.calculateDailyExpenseSummary()[wednesday] ?? 0,
                  thuAmount: value.calculateDailyExpenseSummary()[thursday] ?? 0,
                  friAmount: value.calculateDailyExpenseSummary()[friday] ?? 0,
                  satAmount: value.calculateDailyExpenseSummary()[saturday] ?? 0,
              ),
            ),
          ),
        ],
      )
    );
  }
}