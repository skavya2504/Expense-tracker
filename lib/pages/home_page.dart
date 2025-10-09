import 'package:expense_tracker_app/components/expense_summary.dart';
import 'package:expense_tracker_app/components/expense_tile.dart';
import 'package:expense_tracker_app/data/expense_data.dart';
import 'package:expense_tracker_app/models/expense_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key,});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // text controller
  final newExpenseNameController = TextEditingController();
  final newExpenseAmountController = TextEditingController();

  @override
  void initState(){
    super.initState();
    //prepare data on start up
    Provider.of<ExpenseData>(context,listen: false).prepareData();
  }

  //add new expense
  void addNewExpense(){
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Add New Expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //expensename
              TextField(
                controller: newExpenseNameController,
                decoration: const InputDecoration(
                  hintText: "Expense Name",
                ),
              ),
              //expenseamount
              TextField(
                controller: newExpenseAmountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "Amount",
                ),
              ),
            ],
          ),
          actions: [
            //save
            MaterialButton(
              onPressed: save,
              child: Text('Save'),
            ),
            //cancel
            MaterialButton(
                onPressed: cancel,
                child: Text('Cancel'),
            )
          ],
        )
    );
  }
  //delete expense
  void deleteExpense(ExpenseItem expense){
    Provider.of<ExpenseData>(context,listen: false).deleteExpense(expense);
  }

//save
  void save(){
    //save only if all fields are filled
    if(newExpenseNameController.text.isNotEmpty&&newExpenseAmountController.text.isNotEmpty){
      ExpenseItem newExpense = ExpenseItem(
          name: newExpenseNameController.text,
          amount: newExpenseAmountController.text,
          dateTime: DateTime.now()
      );
      Provider.of<ExpenseData>(context,listen: false).addNewExpense(newExpense);
    }
  Navigator.pop(context);
  clear();
  }
//cancel
  void cancel(){
    Navigator.pop(context);
    clear();
  }
//clear textfields
  void clear(){
    newExpenseAmountController.clear();
    newExpenseNameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseData>(
        builder: (context,value,child) => Scaffold(
          backgroundColor: Colors.grey[300],
          floatingActionButton: FloatingActionButton(
            onPressed: addNewExpense,
            child: Icon(Icons.add),
          ),
          body: ListView(
            children: [
              //bar graph
              ExpenseSummary(startofweek: value.startOfWeekDate()),
              //expenses
              ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: value.getAllExpenseList().length,
                itemBuilder: (context, index) => ExpenseTile(
                  name: value.getAllExpenseList()[index].name,
                  amount: value.getAllExpenseList()[index].amount,
                  dateTime: value.getAllExpenseList()[index].dateTime,
                  deleteTapped: (p0) => deleteExpense(value.getAllExpenseList()[index]),
                ),
              ),
            ],)
        )
    );
  }
}
