import 'package:http/http.dart' as http;
import 'dart:convert';

class Newsarticle {
  String apiKey = "174e81982e404fd1ad6020f187f7a8bc";
  List news = [];

  Future<void> getNews() async {
    String url =
        "http://newsapi.org/v2/top-headlines?country=in&excludeDomains=stackoverflow.com&sortBy=publishedAt&language=en&apiKey=$apiKey";

    var response = await http.get(Uri.parse(url));

    var jsonData = jsonDecode(response.body);

    if (jsonData['status'] == "ok") {
      jsonData["articles"].forEach((element) {
        if (element['urlToImage'] != null && element['description'] != null) {
          print(element['title']);
        }
      });
    }
  }
}
