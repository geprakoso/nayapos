import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductGrid extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final List<Product> products;
  final ValueChanged<String> onCategorySelected;
  final ValueChanged<Product> onAddToCart;

  const ProductGrid({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.products,
    required this.onCategorySelected,
    required this.onAddToCart,
  });

  String _formatCurrency(double amount) {
    String result = amount.toStringAsFixed(0);
    result = result.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp $result';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Categories
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((category) {
                final isSelected = category == selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    avatar: category == 'All'
                        ? Icon(
                            Icons.apps,
                            size: 18,
                            color: isSelected ? Colors.white : null,
                          )
                        : null,
                    label: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : null,
                        fontWeight: isSelected ? FontWeight.bold : null,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF1D7AF3),
                    showCheckmark: false,
                    onSelected: (_) => onCategorySelected(category),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        // Products Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(
              16.0,
            ).copyWith(bottom: 100), // Extra padding for mobile FAB
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                color: colorScheme.surface,
                child: InkWell(
                  onTap: () => onAddToCart(product),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SizedBox(
                            width: double.infinity,
                            child: Stack(
                              children: [
                              // Rounded Image
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: product.imageUrl.startsWith('assets/')
                                      ? Image.asset(
                                          product.imageUrl,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          color: colorScheme.surfaceContainerHighest,
                                          child: Center(
                                            child: Text(
                                              product.imageUrl,
                                              style: const TextStyle(fontSize: 48),
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                              // Stock Badge
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Stock: 12',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1A237E), // Navy blue
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _formatCurrency(product.price),
                                style: textTheme.bodyLarge?.copyWith(
                                  color: const Color(0xFF2196F3), // Bright blue
                                  fontWeight: FontWeight.w900,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
