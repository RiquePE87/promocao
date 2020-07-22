import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:promocao/blocs/product_bloc.dart';
import 'package:promocao/blocs/sales_bloc.dart';
import 'package:promocao/screens/promocao_form.dart';
import 'package:promocao/widgets/sale_card.dart';

class PromocaoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    
    final _bloc = SalesBloc();

    return Scaffold(
      appBar: AppBar(
        title: Text("Promoções"),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
      ),
      body: Container(
        child: Padding(
            padding: EdgeInsets.all(8.0),
            child: StreamBuilder<List<DocumentSnapshot>>(
                stream: _bloc.outSales,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.data.length == 0) {
                    return Center(
                      child: Text("Nenhuma Promoção Encontrada"),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (context,index) {
                        return SaleCard(snapshot.data[index]);
                      },
                    );
                  }
                })),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue[900],
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => PromocaoForm()));
          }),
    );
  }
}
