import 'package:woocommerce/woocommerce.dart';
import 'package:woocommerce_api/woocommerce_api.dart';

class WooCommerceREST {
  final url = 'https://devapp.likebag.com.br';
  final ck = 'ck_a6f60519bab57baf293566a05e345c3d13cf06f4';
  final cs = 'cs_6a6d28788191d234f25b70577a7c2fab12557793';
  WooCommerce wooCommerceApi;

  WooCommerceREST() {
    wooCommerceApi =
        WooCommerce(consumerKey: ck, consumerSecret: cs, baseUrl: url);
  }

  Future getCategories() async {
    List<WooProductCategory> categories;

    try {
      categories = await wooCommerceApi.getProductCategories(perPage: 100);
      //   getAsync('products/categories?per_page=100');
    } catch (e) {
      print(e);
    }
    return categories;
  }

  void createSale(List<dynamic> saleItems) async {
    if (saleItems.length != 0) {
      _createSaleSimple(saleItems[0]);
      _createSaleVariable(saleItems[1]);
    }
  }

  void cancelSale() {}

  void cancelSimpleProduct(int id) async {
    var data = {
      "sale_price": "",
      "date_on_sale_from": "",
      "date_on_sale_to": "",
    };
    wooCommerceApi.post(
        "products/$id", data); //postAsync("products/$id", data);
  }

  void cancelVariableProduct(WooProduct product) async {
    var data = {
      "sale_price": "",
      "date_on_sale_from": "",
      "date_on_sale_to": "",
    };
    product.variations.forEach((v) {
      wooCommerceApi.post("products/${product.id}/variations/$v", data);
    });
  }

  void _createSaleSimple(List<Map> products) async {
    Map<dynamic, dynamic> dataSimple = {"update": {}};
    dataSimple["update"] = products;
    try {
      var create = await wooCommerceApi.post("products/batch", dataSimple);
    } catch (e) {
      print(e);
    }
  }

  void _createSaleVariable(List<Map> products) {
    Map<dynamic, dynamic> dataVariation = {"update": {}};
    products.forEach((product) async {
      try {
        dataVariation["update"] = product["variations"];
        var create = await wooCommerceApi.post(
            "products/${product["id"]}/variations/batch", dataVariation);
      } catch (e) {
        print(e);
      }
    });
  }

  Future getProducts() async {
    List<dynamic> products = await wooCommerceApi.getProducts(perPage: 100);
    // getAsync('products');

    return products;
  }

  Future getProductsByCategory(int category) async {
    List<dynamic> products;
    try {
      products = await wooCommerceApi.getProducts(
          category: category.toString(), perPage: 100);
      //.getAsync('products?category=${category.toString()}&per_page=100');
    } catch (e) {
      print(e);
    }
    return products;
  }

  Future getProduct(int productId) async {
    var product = await wooCommerceApi.getProductById(id: productId);
    return product;
  }
}
