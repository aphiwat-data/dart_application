// for json decode
import 'dart:convert';
// for http connection
import 'package:http/http.dart' as http;

void main() async {
  print('Getting data...');
  // Observe async and await
  final url = Uri.parse('https://jsonplaceholder.typicode.com/posts/1');
  // final url = Uri.https('jsonplaceholder.typicode.com', '/posts/1');
  final response = await http.get(url);
  if (response.statusCode != 200) {
    print(response.statusCode);
    print('Connection failed');
    return;
  }
  // print(response.body);
  final jsonResult = json.decode(response.body) as Map<String, dynamic>;
  print("Title: ${jsonResult['title']}");
  print("Body: ${jsonResult['body']}");
}
