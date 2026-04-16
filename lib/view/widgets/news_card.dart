import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../model/news_model.dart';
import '../detail_screen.dart';

class NewsCard extends StatelessWidget {
  final News news;

  const NewsCard({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailScreen(news: news)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              // Ảnh bo góc cực lớn (Style Minimalist)
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: CachedNetworkImage(
                  imageUrl: news.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  errorWidget: (context, url, error) => CachedNetworkImage(
                    imageUrl: 'https://picsum.photos/seed/${news.title.hashCode}/400/600',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Nút "+" nhỏ ở góc dưới bên phải như trong ảnh mẫu
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                    ],
                  ),
                  child: const Icon(Icons.add, size: 20, color: Colors.black87),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Tiêu đề ngắn gọn bên dưới ảnh
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              news.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
