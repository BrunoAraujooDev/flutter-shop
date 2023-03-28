import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/exception/http_exception.dart';
import 'package:shop/models/product.dart';
import 'package:shop/utils/constants.dart';

class ProductList with ChangeNotifier {
  final List<Product> _items = [];

  List<Product> get items => [..._items];

  int get itemsCount {
    return _items.length;
  }

  Future<void> loadProducts() async {
    _items.clear();
    final response =
        await http.get(Uri.parse('${Constants.PRODUCT_BASE_URL}.json'));

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
    final response =
        await http.post(Uri.parse('${Constants.PRODUCT_BASE_URL}.json'),
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

  Future<void> updateProduct(Product product) async {
    int index = _items.indexWhere((element) => element.id == product.id);

    if (index >= 0) {
      await http.patch(
          Uri.parse('${Constants.PRODUCT_BASE_URL}/${product.id}.json'),
          body: jsonEncode({
            'name': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
          }));
      _items[index] = product;
      notifyListeners();
    }
  }

  Future<void> removeProduct(Product product) async {
    int index = _items.indexWhere((element) => element.id == product.id);

    if (index >= 0) {
      final product = _items[index];
      _items.remove(product);
      notifyListeners();

      final response = await http.delete(
          Uri.parse('${Constants.PRODUCT_BASE_URL}/${product.id}.json'));

      if (response.statusCode >= 400) {
        _items.insert(index, product);
        notifyListeners();

        throw HttpError(
            msg: 'Não foi possível excluir o produto.',
            statusCode: response.statusCode);
      }
    }
  }
}
