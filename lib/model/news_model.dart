class News {
  final String title;
  final String body;
  final String imageUrl;
  final DateTime publishedAt;
  final String url;
  bool isFavorite;

  News({
    required this.title,
    required this.body,
    required this.imageUrl,
    required this.publishedAt,
    required this.url,
    this.isFavorite = false,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    // Logic: Nếu json['image'] null hoặc rỗng, lấy ảnh ngẫu nhiên từ picsum để ứng dụng luôn đẹp
    String apiImage = json['image'] ?? '';
    String fallbackImage = 'https://picsum.photos/seed/${json['title'].hashCode}/600/400';
    
    return News(
      title: json['title'] ?? 'Không có tiêu đề',
      body: json['description'] ?? 'Không có nội dung tóm tắt',
      imageUrl: apiImage.isNotEmpty ? apiImage : fallbackImage,
      publishedAt: DateTime.parse(json['publishedAt'] ?? DateTime.now().toIso8601String()),
      url: json['url'] ?? '',
    );
  }
}
