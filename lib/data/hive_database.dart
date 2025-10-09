import 'package:hive/hive.dart';

import '../models/expense_item.dart';

class HiveDataBase{
  //reference our box
  final _myBox = Hive.box("new_expense_database_3");
  //write data
  void saveData(List<ExpenseItem> allExpense){
    //converting expense items into basic types to store in our database
    // storing each item as a list containing {name,amount,dateTime}
    List<List<dynamic>> allExpensesFormatted = [];

    for(var expense in allExpense){
      //converting each item into a list os storable types(string,datetime etc
      List<dynamic> expenseFormatted = [
        expense.name,
        expense.amount,
        expense.dateTime,
      ];
      allExpensesFormatted.add(expenseFormatted);
    }
    //storing in database
    _myBox.put("ALL_EXPENSES", allExpensesFormatted);
  }

  //read data
  List<ExpenseItem> readData(){
    List savedExpenses = _myBox.get("ALL_EXPENSES") ?? [];
    List<ExpenseItem> allExpenses = [];

    for(int i=0;i<savedExpenses.length;i++){
      String name = savedExpenses[i][0];
      String amount = savedExpenses[i][1];
      DateTime dateTime = savedExpenses[i][2];

      ExpenseItem expense = ExpenseItem(
          name: name,
          amount: amount,
          dateTime: dateTime
      );
      allExpenses.add(expense);
    }
    return allExpenses;
  }

}