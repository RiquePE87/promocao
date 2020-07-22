// import 'package:flutter/material.dart';

// class ProductsExpandedList extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//               child: StreamBuilder<List<dynamic>>(
//                   stream: _bloc.outCategories,
//                   builder: (context, snapshot) {
//                     if (!snapshot.hasData) {
//                       return Center(
//                         child: CircularProgressIndicator(),
//                       );
//                     } else if (snapshot.data.length == 0) {
//                       return Center(
//                         child: Text("Nenhuma Categoria Encontrada!"),
//                       );
//                     } else {
//                       return ListView.builder(
//                           itemCount: snapshot.data.length,
//                           itemBuilder: (context, index) {
//                             return CategoryCard(
//                               category: snapshot.data[index],
//                               context: context,
//                             );
//                           });
//                     }
//                   }),
//             )
//   }
// }