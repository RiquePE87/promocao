class ProductValidator {
  String validatePrice({String text, String discountType}) {
    double price = double.tryParse(text);

    if (price != null) {
      if (discountType == "Valor Fixo") {
        if (!text.contains(".") || text.split(".")[1].length != 2) {
          return "Utilize 2 casas decimais";
        }
      } else {
        if (!text.contains(".") || text.split(".")[1].length != 1) {
          return "Utilize 1 casa decimal";
        }
      }
    }
  }

  String validateProductsList(List list) {
    if (list.length == 0) {
      return "Adicione pelo menos um produto";
    }
  }
}

String validateSaleDateTime(List list) {
  if (list.length == 0) {
    return "Selecione o périodo da promoção";
  }
}
