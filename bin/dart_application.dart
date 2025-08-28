// import ตามที่คุณมี
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

const String base = 'http://localhost:3000';
int? currentUserId;
String? currentUsername;

Future<void> main() async {
  print("===== Expense Menu =====");
  print("1. Show All");
  print("2. Show Today");
  print("3. Search");
  print("4. Exit");
  stdout.write(">> ");
  final choice = stdin.readLineSync();

  if (choice == "1") {
    await showAll();
  } else if (choice == "2") {
    await showToday();
  } else if (choice == "3") {
    await searchExpense();
  } else {
    print("Bye!");
  }
}

Future<void> showAll() async {
  final url = Uri.parse('$base/expenses?user_id=$currentUserId');
  final res = await http.get(url);
  if (res.statusCode == 200) {
    final list = jsonDecode(res.body) as List;
    _printExpenses(list, header: "===== All Expenses =====");
  } else {
    print("Error ${res.statusCode}: ${res.body}");
  }
}

Future<void> showToday() async {
  final url = Uri.parse('$base/expenses/today?user_id=$currentUserId');
  final res = await http.get(url);
  if (res.statusCode == 200) {
    final list = jsonDecode(res.body) as List;
    _printExpenses(list, header: "===== Today Expenses =====");
  } else {
    print("Error ${res.statusCode}: ${res.body}");
  }
}

Future<void> searchExpense() async {
  stdout.write("Keyword: ");
  final keyword = stdin.readLineSync()?.trim();
  if (keyword == null || keyword.isEmpty) return;
  final url = Uri.parse(
    '$base/expenses/search?user_id=$currentUserId&q=$keyword',
  );
  final res = await http.get(url);
  if (res.statusCode == 200) {
    final list = jsonDecode(res.body) as List;
    _printExpenses(list, header: "===== Search Result =====");
  } else {
    print("Error ${res.statusCode}: ${res.body}");
  }
}

void _printExpenses(List list, {required String header}) {
  print(header);
  for (final e in list) {
    final m = e as Map<String, dynamic>;
    print("${m['id']}. ${m['item']} : ${m['paid']}฿ : ${m['date']}");
  }
}
