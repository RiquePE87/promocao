import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:promocao/blocs/product_bloc.dart';
import 'package:promocao/widgets/list_product_wdget.dart';
import 'package:promocao/widgets/product_card.dart';
import 'package:woocommerce/woocommerce.dart';

class CategoryCard extends StatefulWidget {
  final WooProductCategory category;
  ProductBloc _bloc;
  ProductBloc _prodBloc;
  final BuildContext context;

  CategoryCard({this.category, this.context}) {
    _bloc = BlocProvider.of<ProductBloc>(context);
    //_prodBloc = ProductBloc(false);
  }

  @override
  _CategoryCardState createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard>
    with AutomaticKeepAliveClientMixin {
  ProductBloc _prodBloc = ProductBloc(false);

  List<Map<String, dynamic>> products = [];
  bool value = false;
  bool checkCategory = false;
  bool checkProduct = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _prodBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Card(
      child: ExpansionTile(
        onExpansionChanged: (value) =>
            _prodBloc.loadProducts(widget.category.id),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            StreamBuilder<bool>(
                initialData: value,
                stream: _prodBloc.outCheck,
                builder: (context, snapshot) {
                  return Checkbox(
                      value: checkCategory,
                      onChanged: (bool value) {
                        setState(() {
                          checkCategory = value;
                          widget._bloc
                              .addCategory(checkCategory, widget.category.id);
                        });
                      });
                }),
            Text(widget.category.name)
          ],
        ),
        children: <Widget>[
          Container(
              height: 150,
              child: StreamBuilder<List<dynamic>>(
                  stream: _prodBloc.outProducts,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.data.length == 0) {
                      return Center(
                        child: Text("Nenhum Produto"),
                      );
                    } else {
                      return ListProductWidget(
                        context: context,
                        initialValue: snapshot.data,
                        isChecked: checkCategory,
                      );
                    }
                  }))
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
