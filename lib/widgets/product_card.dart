import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:promocao/blocs/product_bloc.dart';
import 'package:woocommerce/models/products.dart';

class ProductCard extends StatefulWidget {
  final WooProduct product;
  ProductBloc _bloc;
  final BuildContext context;
  final bool isChecked;

  ProductCard({this.context, this.product, this.isChecked}) {
    _bloc = BlocProvider.of<ProductBloc>(context);
  }

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool check = false;
  @override
  Widget build(BuildContext context) {
    bool checkProduct = widget.isChecked;
    return Container(
      child: Row(
        children: <Widget>[
          Checkbox(
              value: checkProduct ? checkProduct : check,
              onChanged: (bool value) {
                setState(() {
                  checkProduct = value;
                  check = value;
                  widget._bloc.addProduct(
                      checkProduct ? checkProduct : check, widget.product);
                });
              }),
          Text(widget.product.name)
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget._bloc.dispose();
    super.dispose();
  }
}
