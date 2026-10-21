
import 'package:flutter/material.dart';

class ProductDetailsScreen extends StatelessWidget {

  final dynamic product;

  const ProductDetailsScreen(this.product, {super.key});

  @override
  Widget build(BuildContext context) {

    // Dashboard URL
    final String dashboardUrl = 'https://0p81xswl-7133.uks1.devtunnels.ms/';

    // Image Path
    final String imagePath =
        product['imageUrl']?.toString() ?? '';

    // Complete Image URL
    final String imageUrl = imagePath.isEmpty
        ? ''
        : Uri.parse(dashboardUrl)
        .resolve(imagePath)
        .toString();

    return Scaffold(

      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: Colors.indigo,
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            // Product Image
            SizedBox(
              width: double.infinity,
              height: 300,

              child: imageUrl.isNotEmpty
                  ? Image.network(
                imageUrl,
                fit: BoxFit.contain,

                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.image_not_supported,
                    size: 100,
                  );
                },
              )
                  : const Icon(
                Icons.image,
                size: 100,
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  // Product Name
                  Text(
                    product['name']?.toString() ?? '',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Product Price
                  Text(
                    '${product['price']} SAR',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Divider(),

                  const SizedBox(height: 15),

                  // Product Category
                  Text(
                    'Category ID: ${product['categoryId'] ?? 'N/A'}',
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}