import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/exception/http_exception.dart';
import 'package:shop/models/product.dart';
import 'package:shop/utils/constants.dart';

class ProductList with ChangeNotifier {
  final List<Product> _items;
  final String _userId;
  final String _token;

  ProductList([this._token = '', this._userId = '', this._items = const []]);

  List<Product> get items => [..._items];

  int get itemsCount {
    return _items.length;
  }

  Future<void> loadProducts() async {
    _items.clear();
    final response = await http
        .get(Uri.parse('${Constants.PRODUCT_BASE_URL}.json?auth=$_token'));

    if (response.body == 'null') return;

    final favoriteResponse = await http.get(
      Uri.parse('${Constants.USER_FAVORITE_URL}/$_userId.json?auth=$_token'),
    );

    Map<String, dynamic> favData = favoriteResponse.body == 'null'
        ? {}
        : jsonDecode(favoriteResponse.body);

    Map<String, dynamic> data = jsonDecode(response.body);

    data.forEach((productId, productData) {
      final isFavorite = favData[productId] ?? false;

      _items.add(Product(
        id: productId,
        title: productData['name'],
        description: productData['description'],
        price: productData['price'],
        imageUrl: productData['imageUrl'],
        isFavorite: isFavorite,
      ));
    });

    notifyListeners();
  }

  List<Product> get favoriteItems =>
      _items.where((prod) => prod.isFavorite).toList();

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
    final response = await http.post(
        Uri.parse('${Constants.PRODUCT_BASE_URL}.json?auth=$_token'),
        body: jsonEncode({
          'name': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
        }));
    final id = jsonDecode(response.body)['name'];
    _items.add(Product(
      id: id,
      description: product.description,
      imageUrl: product.imageUrl,
      title: product.title,
      price: product.price,
    ));
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    int index = _items.indexWhere((element) => element.id == product.id);

    if (index >= 0) {
      await http.patch(
          Uri.parse(
              '${Constants.PRODUCT_BASE_URL}/${product.id}.json?auth=$_token'),
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

      final response = await http.delete(Uri.parse(
          '${Constants.PRODUCT_BASE_URL}/${product.id}.json?auth=$_token'));

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
