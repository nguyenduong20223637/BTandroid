import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/news_model.dart';

class NewsService {
  // Đã cập nhật API Key của bạn
  static const String _apiKey = '16bf4363224f1ed348e808285fad782b';
  // URL lấy tin tức công nghệ từ Việt Nam bằng tiếng Việt
  static const String _url = 'https://gnews.io/api/v4/top-headlines?country=vn&lang=vi&category=technology&apikey=$_apiKey';

  Future<List<News>> fetchNews() async {
    try {
      final response = await http.get(Uri.parse(_url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> articles = data['articles'];
        return articles.map((json) => News.fromJson(json)).toList();
      } else {
        throw Exception('Lỗi từ máy chủ GNews: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối hoặc lấy tin tức tiếng Việt: $e');
    }
  }
}
