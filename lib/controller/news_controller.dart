import 'package:flutter/material.dart';
import '../model/news_model.dart';
import '../data/news_service.dart';

class NewsController with ChangeNotifier {
  final NewsService _service = NewsService();
  
  List<News> _items = [];
  List<News> _filteredItems = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<News> get items => _searchQuery.isEmpty ? _items : _filteredItems;
  List<News> get favoriteItems => _items.where((item) => item.isFavorite).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchNews() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await _service.fetchNews();
      _filterNews(_searchQuery);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cập nhật để dùng URL làm định danh duy nhất (vì GNews không có ID số)
  void toggleFavorite(String url) {
    final index = _items.indexWhere((item) => item.url == url);
    if (index != -1) {
      _items[index].isFavorite = !_items[index].isFavorite;
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query;
    _filterNews(query);
    notifyListeners();
  }

  void _filterNews(String query) {
    if (query.isEmpty) {
      _filteredItems = [];
    } else {
      _filteredItems = _items
          .where((item) => item.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }
}
