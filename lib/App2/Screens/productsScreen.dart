import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Hotel/Data/conncetion.dart';
import '../../Hotel/app_theme.dart';
import '../../Hotel/productDetailsScreen.dart';
import '../providers/ProductProvider.dart';


class ProductsScreen extends StatefulWidget {
  const ProductsScreen(this.userId, {super.key});

  final int userId;

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  String _buildImageUrl(String imagePath) {
    if (imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) return imagePath;

    return Uri.parse(ConnectionString.imagesBaseUrl)
        .resolve(imagePath)
        .toString();
  }

  Widget _imagePlaceholder(IconData icon) {
    return Container(
      color: AppColors.background,
      child: Center(child: Icon(icon, size: 56, color: Colors.grey)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final productsList = provider.products;

    return Scaffold(
      appBar: buildAppBar('Products'),
      body: Builder(
        builder: (context) {
          if (provider.isLoading && productsList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && productsList.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.loadProducts(force: true),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (productsList.isEmpty) {
            return const Center(child: Text('No Products Found'));
          }

          return RefreshIndicator(
            color: AppColors.gold,
            onRefresh: () => provider.loadProducts(force: true),
            child: GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(14),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.75,
              ),
              itemCount: productsList.length,
              itemBuilder: (context, index) {
                final product = productsList[index];

                final String name =
                (product['productName'] ?? product['name'] ?? '')
                    .toString();

                final String imagePath =
                (product['productImage'] ?? product['imageUrl'] ?? '')
                    .toString();

                final String imageUrl = _buildImageUrl(imagePath);

                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductDetailsScreen(product, widget.userId),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: imageUrl.isNotEmpty
                                  ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) {
                                  return _imagePlaceholder(
                                    Icons.image_not_supported,
                                  );
                                },
                              )
                                  : _imagePlaceholder(Icons.image),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 12,
                          ),
                          child: Column(
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${product['price']} SAR',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: AppColors.goldDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}