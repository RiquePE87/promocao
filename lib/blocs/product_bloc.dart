import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:promocao/blocs/woo_commerce.dart';
import 'package:rxdart/subjects.dart';
import 'package:woocommerce/woocommerce.dart';

class ProductBloc extends BlocBase {
  final wooComerce = WooCommerceREST();
  final bool isCategory;

  Firestore _firestore = Firestore.instance;

  List<WooProduct> productsList = [];
  List<WooProduct> prodList = [];
  List<WooProductCategory> categories = [];
  List<Map<String, dynamic>> products = [];
  List<List<Map>> saleProducts = [];

  final _productsController = BehaviorSubject<List<WooProduct>>();
  final _saleDateController = BehaviorSubject<List<DateTime>>();
  final _discountTypeController = BehaviorSubject<String>();
  final _discountController = BehaviorSubject<String>();
  final _productsListController = BehaviorSubject<List<Map<String, dynamic>>>();
  final _categoriesController = BehaviorSubject<List<WooProductCategory>>();
  final _categoryController = BehaviorSubject<String>();
  final _productController = BehaviorSubject<Map<String, dynamic>>();
  final _checkController = BehaviorSubject<bool>();
  final _checkProductController = BehaviorSubject<bool>();
  final _messageController = BehaviorSubject<String>();

  Stream<List<WooProduct>> get outProducts => _productsController.stream;
  Stream<String> get outDiscount => _discountController.stream;
  Stream<List<DateTime>> get outSaleDate => _saleDateController.stream;
  Stream<List<Map<String, dynamic>>> get outProductsList =>
      _productsListController.stream;
  Stream<List<dynamic>> get outCategories => _categoriesController.stream;
  StreamSink<String> get inCategory => _categoryController.sink;
  Sink<Map<String, dynamic>> get inProduct => _productController.sink;
  Stream<bool> get outCheck => _checkController.stream;
  StreamSink<bool> get inCheck => _checkController.sink;
  Stream<bool> get outProductCheck => _checkProductController.stream;
  Function(String) get changeDiscount => _discountController.sink.add;
  Function(List<DateTime>) get changeSaleDate => _saleDateController.sink.add;
  Function(String) get changeDiscountType => _discountTypeController.sink.add;
  Stream<String> get outMessage => _messageController;

  ProductBloc(this.isCategory) {
    if (isCategory) {
      _loadCategories();
    }
  }

  void _addProductListener() {
    _checkController.listen((state) {
      if (state) {
        //prodList.add();
      }
    });
  }

  List<List<Map>> createSaleItems() {
    String discountType = _discountTypeController.stream.value;
    List<DateTime> saleDate = _saleDateController.stream.value;
    String discount = _discountController.stream.value;
    //List<WooProduct> products = productsList;
    List<Map> saleProductsVariable = [];
    List<Map> saleProductsSimple = [];
    double discountValue;
    double discountPercentage;
    bool onSale = false;

    if (discountType == "Valor Fixo") {
      discountValue = double.parse(discount);
    } else {
      discountPercentage = double.parse(discount);
    }

    if (productsList.length == 0) {
      _messageController
          .add("Adicione pelo menos um produto ou categoria a promoção");
    }else if (saleDate == null){
      _messageController
          .add("Selecione o período da promoção!");
    }
     else {
      productsList.forEach((product) {
        Map<String, dynamic> saleItemSimple = {};
        Map<String, dynamic> saleItemVariable = {};
        double salePrice;
        if (discountPercentage != null) {
          salePrice = double.tryParse(product.price) -
              (double.tryParse(product.price) * (discountPercentage / 100));
        } else {
          salePrice = double.tryParse(product.price) - discountValue;
        }

        if (product.onSale == true) {
          onSale = true;
          productsList.removeWhere((element) => element.id == product.id);

          _messageController
              .add("O produto ${product.name} já está em promoção");
        } else {
          if (product.type == "simple") {
            saleItemSimple.addAll({
              "id": product.id,
              "sale_price": salePrice.toStringAsFixed(2),
              "date_on_sale_from": saleDate[0].toIso8601String(),
              "date_on_sale_to": saleDate[1].toIso8601String(),
            });
            saleProductsSimple.add(saleItemSimple);
          } else if (product.type == "variable") {
            List<Map> pl = [];
            product.variations.forEach((v) {
              Map p = {
                "id": v,
                "sale_price": salePrice.toStringAsFixed(2),
                "date_on_sale_from": saleDate[0].toIso8601String(),
                "date_on_sale_to": saleDate[1].toIso8601String(),
              };
              pl.add(p);
            });
            saleItemVariable.addAll({"id": product.id, "variations": pl});
            saleProductsVariable.add(saleItemVariable);
          }
        }
      });
      if (!onSale) {
        saleProducts.add(saleProductsSimple);
        saleProducts.add(saleProductsVariable);
      } else {
        //_messageController.add("Erro ao criar promoção");
      }
    }

    return saleProducts;
  }

  Future<List<WooProduct>> getCancelList(DocumentSnapshot doc) async {
    List<dynamic> products = doc.data["Products"];
    List<WooProduct> list = [];

    for (Map m in products) {
      var data = await wooComerce.getProduct(m["id"]);
      list.add(data);
    }

    // products.forEach((product) async {
    //   var data = await wooComerce.getProduct(product["id"]);
    //   list.add(data);
    // });

    return list;
  }

  void cancelSale(DocumentSnapshot doc) async {
    List<WooProduct> list;
    await getCancelList(doc).then((value) => list = value);

    list.forEach((product) {
      if (product.type == "simple") {
        wooComerce.cancelSimpleProduct(product.id);
      } else if (product.type == "variable") {
        wooComerce.cancelVariableProduct(product);
      }
    });
    _firestore.collection("sales").document(doc.documentID).delete();
  }

  bool publishSale() {
    try {
      List<List<Map>> list = createSaleItems();
      wooComerce.createSale(list);
      saveSale();
      return true;
    } catch (e) {
      return false;
    }
  }

  void saveSale() {
    var list = [];
    var desc = _discountTypeController.stream.value == "Valor Fixo"
        ? "R\$: ${_discountController.stream.value} OFF"
        : "${_discountController.stream.value}% OFF";

    if (productsList.length != 0) {
      productsList.forEach((e) {
        double regularPrice = _discountTypeController.stream.value ==
                "Valor Fixo"
            ? double.tryParse(e.price) -
                double.tryParse(_discountController.stream.value)
            : double.tryParse(e.price) -
                (double.tryParse(e.price) *
                    (double.tryParse(_discountController.stream.value) / 100));
        list.add({
          "id": e.id,
          "name": e.name,
          "price": double.parse(e.price.toString()).toStringAsFixed(2),
          "regular_price": regularPrice.toStringAsFixed(2)
        });
      });

      var data = {
        "Discount": desc,
        "StartDate": _saleDateController.stream.value[0],
        "EndDate": _saleDateController.stream.value[1],
        "Products": list
      };

      _firestore.collection("sales").add(data);
    }
  }

  Future<List<Map<String, dynamic>>> loadAllProducts() async {
    for (WooProductCategory m in categories) {
      var p = await wooComerce.getProductsByCategory(m.id);
      products.add({"category": m.name, "products": p});
    }
    return products;
  }

  void _addProductsList(List<dynamic> cat) async {
    for (Map m in cat) {
      var p = await wooComerce.getProductsByCategory(m["id"]);
      products.add({"category": m["name"], "products": p});
    }
    _productsListController.add(products);
  }

  // void _addListener() {
  //   _productsListController.listen((event) {
  //     product.add(event);
  //   });
  // }

  void _loadCategories() async {
    categories = await wooComerce.getCategories();
    _categoriesController.add(categories);
  }

  void loadProducts(int category) async {
    //outProducts.drain();
    List<WooProduct> products =
        await wooComerce.getProductsByCategory(category);

    _productsController.add(products);
  }

  Future<List<dynamic>> loadProductsCategory(int category) async {
    List<dynamic> products = await wooComerce.getProductsByCategory(category);

    return products;
  }

  void addProduct(bool checkValue, WooProduct product) {
    if (checkValue) {
      productsList.add(product);
    } else {
      productsList.remove(product);
    }
  }

  void addCategory(bool checkValue, int category) async {
    List<WooProduct> products;
    products = await wooComerce.getProductsByCategory(category);

    if (checkValue && products != null) {
      products.forEach((p) {
        productsList.add(p);
      });
    } else if (!checkValue && products != null) {
      for (WooProduct p in products) {
        productsList.removeWhere((element) => element.id == p.id);
      }
    }
  }

  void onChangedCategory(bool value) {
    _checkController.add(value);

    var list = _productsController.stream.value;
    if (value) {
      for (var p in list) {
        productsList.add(p);
      }
    } else {
      for (var p in list) {
        productsList.remove(p);
      }
    }
    print(productsList);
  }

  void onChangedProduct(bool value) {
    _checkProductController.add(value);
  }

  void updateProducts() {}

  @override
  void dispose() {
    _messageController.close();
    _productsController.close();
    _productsListController.close();
    _categoriesController.close();
    _categoryController.close();
    _productController.close();
    _checkController.close();
    _checkProductController.close();
    _discountController.close();
    _saleDateController.close();
    _discountTypeController.close();
  }
}
