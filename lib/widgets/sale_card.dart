import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:promocao/blocs/product_bloc.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class SaleCard extends StatelessWidget {
  DocumentSnapshot sale;

  SaleCard(this.sale);

  @override
  Widget build(BuildContext context) {
    final ProductBloc _bloc = ProductBloc(false);
    DateTime startDate = sale.data["StartDate"].toDate();
    DateTime endDate = sale.data["EndDate"].toDate();
    int saleDaysCount = endDate.day - startDate.day;
    int daysRemain = endDate.day - DateTime.now().day;

    return Container(
      child: Card(
        child: ExpansionTile(
          title: Text(
            sale.data["Discount"],
            style: TextStyle(
                color: Colors.blue[900],
                fontSize: 18.0,
                fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
              "De ${startDate.day}/${startDate.month}/${startDate.year} à ${endDate.day}/${endDate.month}/${endDate.year}"),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    "Andamento da promoção",
                    style: TextStyle(fontSize: 12.0),
                  ),
                  SizedBox(height: 5),
                  StepProgressIndicator(
                    totalSteps: saleDaysCount,
                    currentStep: daysRemain,
                    progressDirection: TextDirection.rtl,
                    size: 8,
                    padding: 0,
                    selectedColor: Colors.pinkAccent,
                    unselectedColor: Colors.blue[900],
                    roundedEdges: Radius.circular(10),
                  ),
                  SizedBox(height: 5),
                  Divider(
                    color: Colors.black,
                  ),
                  buildList(sale.data["Products"]),
                  Center(
                    child: FlatButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("Atenção!"),
                                content: Text(
                                    "Deseja realmente cancelar a promoção?"),
                                actions: <Widget>[
                                  FlatButton(
                                      onPressed: () {
                                        _bloc.cancelSale(sale);
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("Sim")),
                                  FlatButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("Não")),
                                ],
                              );
                            },
                          );
                        },
                        child: Text("Cancelar Promoção")),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildList(List list) {
    return SizedBox(
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: list.length,
          itemBuilder: (context, index) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(list[index]["name"],
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.w500)),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text("De R\$: ${list[index]["price"]}"),
                    Text("Por R\$: ${list[index]["regular_price"]}"),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
