import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:group_radio_button/group_radio_button.dart';
import 'package:promocao/blocs/product_bloc.dart';
import 'package:promocao/validators/product_validator.dart';
import 'package:promocao/widgets/category_card.dart';
import 'package:promocao/widgets/list_category_widget.dart';

class PromocaoForm extends StatefulWidget {
  @override
  _PromocaoFormState createState() => _PromocaoFormState();
}

class _PromocaoFormState extends State<PromocaoForm>
    with AutomaticKeepAliveClientMixin, ProductValidator {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<DateTime> picked = [];
  List<String> items = ["Valor Percentual", "Valor Fixo"];
  String _value = "Valor Fixo";
  final _bloc = ProductBloc(true);

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _bloc.changeDiscountType.call(_value);

    void _showDatePicker() async {
      picked = await DateRagePicker.showDatePicker(
          context: context,
          initialFirstDate: new DateTime.now(),
          initialDatePickerMode: DateRagePicker.DatePickerMode.day,
          initialLastDate: new DateTime.now().add(Duration(days: 7)),
          firstDate: new DateTime(2020),
          lastDate: new DateTime(2100));
      if (picked != null && picked.length == 2) {
        setState(() {
          _bloc.changeSaleDate.call(picked);
        });
      }
    }

    return BlocProvider<ProductBloc>(
      bloc: _bloc,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Criar Promoção"),
          centerTitle: true,
          backgroundColor: Colors.blue[900],
        ),
        floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.blue[900],
            child: Icon(
              Icons.save,
              color: Colors.white,
            ),
            onPressed: saveSale),
        body: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () {
                          _showDatePicker();
                        },
                      ),
                      Text(
                        picked.isNotEmpty && picked != null
                            ? "De: ${picked[0].day}/${picked[0].month}/${picked[0].year} à ${picked[1].day}/${picked[1].month}/${picked[1].year}"
                            : "Selecione o período da promoção",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 18.0),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: StreamBuilder<String>(
                      stream: _bloc.outDiscount,
                      builder: (context, snapshot) {
                        return TextFormField(
                          validator: (text) {
                            double price = double.tryParse(text);

                            if (price != null) {
                              if (_value == "Valor Fixo") {
                                if (!text.contains(".") ||
                                    text.split(".")[1].length != 2) {
                                  return "Utilize 2 casas decimais";
                                }
                              } else {
                                if (!text.contains(".") ||
                                    text.split(".")[1].length != 1) {
                                  return "Utilize 1 casa decimal";
                                }
                              }
                            }
                            return null;
                          },
                          onChanged: _bloc.changeDiscount,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            alignLabelWithHint: false,
                            prefixText:
                                _value == "Valor Percentual" ? "% " : "R\$:",
                          ),
                        );
                      }),
                ),
                SizedBox(
                  height: 8.0,
                ),
                RadioGroup<String>.builder(
                    groupValue: _value,
                    onChanged: (value) {
                      setState(() {
                        _value = value;
                        _bloc.changeDiscountType.call(_value);
                      });
                    },
                    items: items,
                    itemBuilder: (item) => RadioButtonBuilder(item)),
                StreamBuilder<String>(
                    stream: _bloc.outMessage,
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.hasData ? snapshot.data : "",
                        style: TextStyle(color: Colors.redAccent),
                      );
                    }),
                Expanded(
                  child: StreamBuilder<List<dynamic>>(
                      stream: _bloc.outCategories,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: Column(
                              children: <Widget>[
                                Text("Carregando as Categorias, Aguarde..."),
                                SizedBox(
                                  height: 10,
                                ),
                                CircularProgressIndicator(),
                              ],
                            ),
                          );
                        } else if (snapshot.data.length == 0) {
                          return Center(
                            child: Text("Nenhuma Categoria Encontrada!"),
                          );
                        } else {
                          return ListCategoryWidget(
                            context: context,
                            initialValue: snapshot.data,
                            validator: validateProductsList,
                          );
                          // ListView.builder(
                          //     itemCount: snapshot.data.length,
                          //     itemBuilder: (context, index) {
                          //       return CategoryCard(
                          //         category: snapshot.data[index],
                          //         context: context,
                          //       );
                          //     });
                        }
                      }),
                )
              ],
            )),
      ),
    );
  }

  void saveSale() {
    if (_formKey.currentState.validate()) {
      bool success = _bloc.publishSale();
      if (success) {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
            backgroundColor: Colors.blue[900],
            content: Text("Promoção criada com sucesso")));
        Future.delayed(Duration(seconds: 2))
            .then((value) => Navigator.of(context).pop());
      } else {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text("Erro ao criar promoção")));
      }
    }
  }

  // void saveSale() {
  //   if (_formKey.currentState.validate()) {
  //     _formKey.currentState.save();
  //     _scaffoldKey.currentState.showSnackBar(new SnackBar(
  //         backgroundColor: Colors.pinkAccent,
  //         duration: Duration(minutes: 1),
  //         content: Text("Criando Promoção...",
  //             style: TextStyle(color: Colors.white))));

  //     bool success = _bloc.publishSale();

  //     _scaffoldKey.currentState.removeCurrentSnackBar();

  //     _scaffoldKey.currentState.showSnackBar(new SnackBar(
  //         backgroundColor: Colors.pinkAccent,
  //         content: Text(success ? "Promoção Criada!" : "Erro ao Criar Promoção",
  //             style: TextStyle(color: Colors.white))));

  //     Future.delayed(Duration(seconds: 2))
  //         .then((value) => Navigator.of(context).pop());
  //   }
  // }

  @override
  bool get wantKeepAlive => true;
}
