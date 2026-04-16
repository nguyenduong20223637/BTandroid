import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../controller/news_controller.dart';
import 'widgets/news_card.dart';
import 'favorite_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Tất cả';
  final List<String> _categories = ['Tất cả', 'Công nghệ', 'Kinh doanh', 'Thể thao', 'Khoa học'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Hàm xử lý làm mới dữ liệu và hiển thị SnackBar nếu lỗi
  Future<void> _handleRefresh(NewsController controller) async {
    await controller.fetchNews();
    if (controller.errorMessage != null && controller.items.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi cập nhật: ${controller.errorMessage}'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Thử lại',
            textColor: Colors.white,
            onPressed: () => _handleRefresh(controller),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final newsController = Provider.of<NewsController>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: SafeArea(
        child: RefreshIndicator(
          color: Colors.black,
          onRefresh: () => _handleRefresh(newsController),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Tiêu đề
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Tin Tức', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A))),
                      Text('Dành Cho Bạn', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A))),
                    ],
                  ),
                ),
              ),
              
              // Thanh Tìm kiếm
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(16)),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Tìm kiếm tin tức...',
                        prefixIcon: Icon(Icons.search, color: Colors.black54),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                      ),
                      onChanged: (value) => newsController.search(value),
                    ),
                  ),
                ),
              ),

              // Danh mục
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        bool isSelected = _selectedCategory == _categories[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedCategory = _categories[index]),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.black : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: isSelected ? null : Border.all(color: Colors.grey.shade300),
                              ),
                              child: Text(_categories[index], style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Nội dung chính (Loading, Error, Data)
              _buildContent(newsController),
              
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildContent(NewsController controller) {
    // 1. Hiển thị Loading khi đang tải dữ liệu (Yêu cầu 1.0đ)
    if (controller.isLoading && controller.items.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }

    // 2. Hiển thị thông báo lỗi (Yêu cầu 1.0đ)
    if (controller.errorMessage != null && controller.items.isEmpty) {
      return SliverFillRemaining(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Ối! Không có kết nối mạng',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800]),
              ),
              const SizedBox(height: 8),
              Text(
                controller.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => controller.fetchNews(),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Thử lại ngay'),
              ),
            ],
          ),
        ),
      );
    }

    if (controller.items.isEmpty) {
      return const SliverFillRemaining(child: Center(child: Text('Không tìm thấy tin tức.')));
    }

    // 3. Hiển thị dữ liệu chính
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverMasonryGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 16,
        itemBuilder: (context, index) {
          return NewsCard(news: controller.items[index]);
        },
        childCount: controller.items.length,
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 80,
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, -5))]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home_filled, true, () {}),
          _buildNavItem(Icons.favorite_outline, false, () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoriteScreen()));
          }),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: isActive ? Colors.black : Colors.black38),
          if (isActive) Container(margin: const EdgeInsets.only(top: 4), width: 4, height: 4, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle))
        ],
      ),
    );
  }
}
