import 'package:flutter/material.dart';
import 'package:promocao/screens/promocao_screen.dart';

void main() {
  runApp(Home());
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: "Promoções", home: PromocaoScreen(), debugShowCheckedModeBanner: false,);
  }
}
