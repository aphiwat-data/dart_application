import 'package:dart_application/dart_application.dart' as dart_application;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

/// ==================== Authentication ====================
Future<int?> login() async {
  print("===== Login =====");
  stdout.write("Username: ");
  String? username = stdin.readLineSync()?.trim();
  stdout.write("Password: ");
  String? password = stdin.readLineSync()?.trim();

  if (username == null || password == null || username.isEmpty || password.isEmpty) {
    print("Incomplete input");
    return null;
  }

  final body = {"username": username, "password": password};
  final url = Uri.parse('http://localhost:3000/login');
  final response = await http.post(url, body: body);

  if (response.statusCode == 200) {
    final result = json.decode(response.body);
    print(result["message"]);
    return result["userId"];
  } else if (response.statusCode == 401 || response.statusCode == 500) {
    print(response.body);
    return null;
  } else {
    print("Unknown error");
    return null;
  }
}

/// ==================== Expense Functions ====================
Future<void> allExpenses(int userId) async {
  final url = Uri.parse('http://localhost:3000/expenses/$userId');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final jsonResult = json.decode(response.body) as List;
    int total = 0;
    print("------------- All Expenses -------------");
    for (var exp in jsonResult) {
      final dt = DateTime.tryParse(exp['date'].toString());
      final dtLocal = dt?.toLocal();
      print("${exp['id']}. ${exp['item']} : ${exp['paid']}฿ @ ${dtLocal ?? exp['date']}");
      total += int.tryParse(exp['paid'].toString()) ?? 0;
    }
    print("Total expenses = $total฿");
  } else {
    print("Failed to fetch all expenses");
  }
}

Future<void> todayExpenses(int userId) async {
  final url = Uri.parse('http://localhost:3000/expenses/$userId/today');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final jsonResult = json.decode(response.body) as List;
    int total = 0;
    print("------------ Today's Expenses -----------");
    for (var exp in jsonResult) {
      final dt = DateTime.tryParse(exp['date'].toString());
      final dtLocal = dt?.toLocal();
      print("${exp['id']}. ${exp['item']} : ${exp['paid']}฿ @ ${dtLocal ?? exp['date']}");
      total += int.tryParse(exp['paid'].toString()) ?? 0;
    }
    print("Total expenses = $total฿");
  } else {
    print("Failed to fetch today's expenses");
  }
}

/// TODO: Implement later
Future<void> searchExpenses(int userId) async {
  print("Search function not implemented yet.");
}

Future<void> addExpenses(int userId) async {
  print("Add function not implemented yet.");
}

//Delete function
Future<void> deleteExpenses(int userId) async {
  print("===== Delete an item =====");
  stdout.write("Item id: ");
  String? idInput = stdin.readLineSync()?.trim();

  final expenseId = int.tryParse(idInput ?? '');
  if (expenseId == null) {
    print("Please input a valid number\n");
    return;
  }

  final url = Uri.parse('http://localhost:3000/expenses/delete/$userId/$expenseId');
  final response = await http.delete(url);

  if (response.statusCode == 200) {
    print("Deleted!\n");
  } else if (response.statusCode == 404) {
    print("Expense not found\n");
  } else {
    print("Failed to delete expense");
  }
}

/// ==================== Menu Loop ====================
Future<void> menuLoop(int userId) async {
  while (true) {
    print("========= Expense Tracking App =========");
    print("1. All expenses");
    print("2. Today's expenses");
    print("3. Search expense");
    print("4. Add new expense");
    print("5. Delete an expense");
    print("6. Exit");
    stdout.write("Choose... ");
    String? choice = stdin.readLineSync()?.trim();

    switch (choice) {
      case '1':
        await allExpenses(userId);
        break;
      case '2':
        await todayExpenses(userId);
        break;
      case '3':
        await searchExpenses(userId);
        break;
      case '4':
        await addExpenses(userId);
        break;
      case '5':
        await deleteExpenses(userId);
        break;
      case '6':
        print("----- Bye -----");
        return;
      default:
        print("Invalid choice, please try again.");
    }
  }
}

/// ==================== Entry Point ====================
Future<void> main(List<String> arguments) async {
  print('Hello world: ${dart_application.calculate()}!');
  final userId = await login();
  if (userId != null) {
    await menuLoop(userId);
  }
}
