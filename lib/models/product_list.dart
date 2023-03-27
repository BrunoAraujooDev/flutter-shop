import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/data/dummy_data.dart';
import 'package:shop/models/product.dart';

class ProductList with ChangeNotifier {
  final _url =
      'https://shop-flutter-a67c7-default-rtdb.firebaseio.com/product.json';
  final List<Product> _items = [];

  List<Product> get items => [..._items];

  int get itemsCount {
    return _items.length;
  }

  Future<void> loadProducts() async {
    final response = await http.get(Uri.parse(_url));

    Map<String, dynamic> data = jsonDecode(response.body);

    if (response.body == 'null') return;

    data.forEach((id, product) {
      _items.add(Product(
        id: id,
        title: product['name'],
        description: product['description'],
        price: product['price'],
        imageUrl: product['imageUrl'],
        isFavorite: product['isFavorite'],
      ));
    });

    notifyListeners();
  }

  List<Product> get favoriteItems =>
      _items.where((prod) => prod.isFavorite == true).toList();

  Future<void> saveProduct(Map<String, Object> data) {
    bool hasId = data['id'] != null;

    final product = Product(
      id: hasId ? data['id'] as String : Random().nextDouble().toString(),
      title: data['name'].toString(),
      description: data['description'].toString(),
      price: data['price'] as double,
      imageUrl: data['imageUrl'] as String,
    );

    if (hasId) {
      return updateProduct(product);
    } else {
      return addProduct(product);
    }
  }

  Future<void> addProduct(Product product) async {
    final response = await http.post(Uri.parse(_url),
        body: jsonEncode({
          'name': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'isFavorite': product.isFavorite
        }));
    final id = jsonDecode(response.body)['name'];
    _items.add(Product(
      id: id,
      description: product.description,
      imageUrl: product.imageUrl,
      title: product.title,
      price: product.price,
      isFavorite: product.isFavorite,
    ));
    notifyListeners();
  }

  Future<void> updateProduct(Product product) {
    int index = _items.indexWhere((element) => element.id == product.id);

    if (index >= 0) {
      _items[index] = product;
      notifyListeners();
    }

    return Future.value();
  }

  void removeProduct(Product product) {
    int index = _items.indexWhere((element) => element.id == product.id);

    if (index >= 0) {
      _items.removeWhere((element) => element.id == product.id);
      notifyListeners();
    }
  }
}
