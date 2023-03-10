import 'package:flutter/material.dart';
import 'package:shop/components/product_grid.dart';

enum FilteredOptions { Favorite, All }

class ProductOverviewPage extends StatefulWidget {
  const ProductOverviewPage({super.key});

  @override
  State<ProductOverviewPage> createState() => _ProductOverviewPageState();
}

class _ProductOverviewPageState extends State<ProductOverviewPage> {
  bool _showFavoriteOnly = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Minha loja',
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (_) => [
              const PopupMenuItem(
                child: Text('Somente favoritos'),
                value: FilteredOptions.Favorite,
              ),
              const PopupMenuItem(
                child: Text('Todos'),
                value: FilteredOptions.All,
              ),
            ],
            onSelected: (FilteredOptions selectedValue) {
              setState(() {
                if (selectedValue == FilteredOptions.Favorite) {
                  _showFavoriteOnly = true;
                } else {
                  _showFavoriteOnly = false;
                }
              });
            },
          )
        ],
      ),
      body: ProductGrid(
        showFavoriteOnly: _showFavoriteOnly,
      ),
    );
  }
}
