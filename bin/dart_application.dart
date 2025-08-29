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

  if (username == null ||
      password == null ||
      username.isEmpty ||
      password.isEmpty) {
    print("Incomplete input");
    return null;
  }

  final body = {"username": username, "password": password};
  final url = Uri.parse('http://localhost:3000/login');
  final response = await http.post(url, body: body);

  if (response.statusCode == 200) {
    final result = json.decode(response.body);
    print(result["message"]);
    print("Welcome ${result["username"]} "); // Welcome Messenger
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
      print(
        "${exp['id']}. ${exp['item']} : ${exp['paid']}฿ @ ${dtLocal ?? exp['date']}",
      );
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
      print(
        "${exp['id']}. ${exp['item']} : ${exp['paid']}฿ @ ${dtLocal ?? exp['date']}",
      );
      total += int.tryParse(exp['paid'].toString()) ?? 0;
    }
    print("Total expenses = $total฿");
  } else {
    print("Failed to fetch today's expenses");
  }
}

/// TODO: Implement later
Future<void> searchExpenses(int userId) async {
  print("===== Search Expense =====");
  stdout.write("Keyword: ");
  String? keyword = stdin.readLineSync()?.trim();

  if (keyword == null || keyword.isEmpty) {
    print("No keyword entered");
    return;
  }

  final url = Uri.parse(
    'http://localhost:3000/expenses/$userId/search/$keyword',
  );
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final jsonResult = json.decode(response.body) as List;
    if (jsonResult.isEmpty) {
      print("No results found for \"$keyword\".");
      return;
    }

    print("-------- Search Results --------");
    for (var exp in jsonResult) {
      final dt = DateTime.tryParse(exp['date'].toString());
      final dtLocal = dt?.toLocal();
      print(
        "${exp['id']}. ${exp['item']} : ${exp['paid']}฿ @ ${dtLocal ?? exp['date']}",
      );
    }
  } else {
    print("Failed to search: ${response.body}");
  }
}

Future<void> addExpenses(int userId) async {
  print("===== Add New Expense =====");
  stdout.write("Item name: ");
  String? item = stdin.readLineSync()?.trim();
  stdout.write("Paid (amount): ");
  String? paidStr = stdin.readLineSync()?.trim();

  if (item == null || item.isEmpty || paidStr == null || paidStr.isEmpty) {
    print("Incomplete input");
    return;
  }

  final paid = double.tryParse(paidStr);
  if (paid == null) {
    print("Invalid amount");
    return;
  }

  final url = Uri.parse('http://localhost:3000/expenses/$userId');
  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: json.encode({"item": item, "paid": paid}),
  );

  if (response.statusCode == 200) {
    print("Expense added successfully.");
  } else {
    print("Failed to add expense: ${response.body}");
  }
}

Future<void> deleteExpenses(int userId) async {
  print("===== Delete Expense =====");
  stdout.write("Enter Expense ID to delete: ");
  String? idStr = stdin.readLineSync()?.trim();

  if (idStr == null || idStr.isEmpty) {
    print("No ID entered");
    return;
  }

  final id = int.tryParse(idStr);
  if (id == null) {
    print("Invalid ID");
    return;
  }

  final url = Uri.parse('http://localhost:3000/expenses/$userId/$id');
  final response = await http.delete(url);

  if (response.statusCode == 200) {
    print("Expense deleted successfully.");
  } else {
    print("Failed to delete: ${response.body}");
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
