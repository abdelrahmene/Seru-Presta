import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'cart_page.dart';
import 'invoice_page.dart';
import 'product_detail.dart';
import 'home_content.dart';
import 'profil.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Déclaration des variables
  late PageController _pageController;
  Map<String, dynamic>? selectedProduct;
  bool showProductDetail = false;
  int selectedIndex = 0;
  String selectedCategory = "Shop";
  int selectedCategoryIndex = 0;
  String selectedSubmenu = "";

  final List<Widget> _pages = [
    HomeContent(
      key: const ValueKey('home'),
      selectedCategory: '',
      selectedSubmenu: '',
      onCategorySelected: (_) {},
      onSubmenuSelected: (_) {},
    ),
    CartPage(key: const ValueKey('cart')),
    InvoicePage(key: const ValueKey('invoice')),
    ProfilePage(const ValueKey('profile')),
  ];

  void openProductDetail(Map<String, dynamic> produit) {
    setState(() {
      selectedProduct = produit;
      showProductDetail = true;
    });
  }

  void closeProductDetail() {
    setState(() {
      showProductDetail = false;
      selectedProduct = null;
    });
  }

  @override
  void initState() {
    super.initState();
    // Initialiser le PageController immédiatement
    _pageController = PageController(initialPage: 0);
    
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      setState(() {
        selectedIndex = args['index'] ?? 0;
        selectedCategory = args['category'] ?? "Shop";
        selectedCategoryIndex = _getCategoryIndex(selectedCategory);
      });
    } else if (args != null && args is int) {
      setState(() {
        selectedIndex = args;
      });
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (selectedCategory.isEmpty) {
        setState(() => selectedCategory = "Shop");
      }
      
      // Mettre à jour la page du PageController après que les arguments ont été traités
      _pageController.jumpToPage(selectedCategoryIndex);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/animations/shipImage.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 40, 16, 10),
                child: _buildSearchBar(),
              ),
              if (selectedIndex == 0) _buildCategories(),
              Expanded(
                child: selectedIndex == 0
                    ? _buildSwipeableContent()
                    : _pages[selectedIndex]
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideX(begin: 0.1, duration: 200.ms),
              ),
            ],
          ),
          if (showProductDetail && selectedProduct != null)
            _buildProductOverlay(),
        ],
      ),
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: Colors.blue.shade900,
        style: TabStyle.react,
        items: const [
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.shopping_cart, title: 'Cart'),
          TabItem(icon: Icons.receipt, title: 'Invoice'),
          TabItem(icon: Icons.person, title: 'Profil'),
        ],
        initialActiveIndex: selectedIndex,
        onTap: (index) {
          // Si on revient à l'onglet Home, s'assurer que le PageView est à la bonne page
          if (index == 0 && selectedIndex != 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // Animer vers la page correspondant à la catégorie sélectionnée
              _pageController.animateToPage(
                selectedCategoryIndex,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            });
          }
          setState(() => selectedIndex = index);
        },
      ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, duration: 300.ms),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search for a product...",
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
        prefixIcon: const Icon(Icons.search, color: Colors.white),
        filled: true,
        fillColor: Colors.black.withOpacity(0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildCategories() {
    return Container(
      height: 130,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Our services",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(color: Colors.blueAccent, blurRadius: 5),
                  Shadow(color: Colors.blueAccent, blurRadius: 10),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 90,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCategoryIcon(Icons.store, "Shop"),
                _buildCategoryIcon(Icons.build, "Spare Parts"),
                _buildCategoryIcon(Icons.people, "Crew Change"),
                _buildCategoryIcon(Icons.info, "About Us"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(IconData icon, String label) {
    bool isSelected = selectedCategory == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = label;
          selectedCategoryIndex = _getCategoryIndex(label);
          _pageController.animateToPage(
            selectedCategoryIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });
      },
      child: Container(
        width: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? Colors.blueAccent
                      : Colors.white.withOpacity(0.3),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(color: Colors.blueAccent, blurRadius: 10),
                          BoxShadow(color: Colors.blue, blurRadius: 20),
                        ]
                      : [],
                ),
                child: Icon(icon, color: Colors.white, size: 30),
              ).animate().fadeIn(duration: 500.ms).scale(delay: 200.ms),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductOverlay() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: closeProductDetail,
        child: Container(
          color: Colors.black.withOpacity(0.7),
          child: Center(
            child: FractionallySizedBox(
              widthFactor: 0.9,
              heightFactor: 0.85,
              child: ProductDetailPage(
                produit: selectedProduct!,
                product: {},
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeableContent() {
    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          selectedCategoryIndex = index;
          selectedCategory = _getCategoryLabel(index);
        });
      },
      children: [
        HomeContent(
          key: const ValueKey('shop'),
          selectedCategory: "Shop",
          selectedSubmenu: selectedSubmenu,
          onCategorySelected: (category) {
            setState(() {
              selectedCategory = category;
            });
          },
          onSubmenuSelected: (submenu) {
            setState(() {
              selectedSubmenu = submenu;
            });
          },
        ),
        HomeContent(
          key: const ValueKey('spare_parts'),
          selectedCategory: "Spare Parts",
          selectedSubmenu: selectedSubmenu,
          onCategorySelected: (category) {
            setState(() {
              selectedCategory = category;
            });
          },
          onSubmenuSelected: (submenu) {
            setState(() {
              selectedSubmenu = submenu;
            });
          },
        ),
        HomeContent(
          key: const ValueKey('crew_change'),
          selectedCategory: "Crew Change",
          selectedSubmenu: selectedSubmenu,
          onCategorySelected: (category) {
            setState(() {
              selectedCategory = category;
            });
          },
          onSubmenuSelected: (submenu) {
            setState(() {
              selectedSubmenu = submenu;
            });
          },
        ),
        HomeContent(
          key: const ValueKey('about_us'),
          selectedCategory: "About Us",
          selectedSubmenu: selectedSubmenu,
          onCategorySelected: (category) {
            setState(() {
              selectedCategory = category;
            });
          },
          onSubmenuSelected: (submenu) {
            setState(() {
              selectedSubmenu = submenu;
            });
          },
        ),
      ],
    );
  }

  int _getCategoryIndex(String label) {
    switch (label) {
      case "Shop":
        return 0;
      case "Spare Parts":
        return 1;
      case "Crew Change":
        return 2;
      case "About Us":
        return 3;
      default:
        return 0;
    }
  }

  String _getCategoryLabel(int index) {
    switch (index) {
      case 0:
        return "Shop";
      case 1:
        return "Spare Parts";
      case 2:
        return "Crew Change";
      case 3:
        return "About Us";
      default:
        return "Shop";
    }
  }
}
