import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class SalesBloc extends BlocBase {
  Firestore _firestore = Firestore.instance;
  List<DocumentSnapshot> _sales = [];
  final _salesController = BehaviorSubject<List<DocumentSnapshot>>();
  Stream<List<DocumentSnapshot>> get outSales => _salesController.stream;

  SalesBloc() {
    _addListener();
  }

  void _addListener() {
    _firestore.collection("sales").snapshots().listen((snapshot) {
      _sales = [];
      snapshot.documents.forEach((doc) {
        DateTime date = doc.data["EndDate"].toDate();
        if (date.isBefore(DateTime.now())) {
          _firestore.collection("sales").document(doc.documentID).delete();
        }else
        _sales.add(doc);
      });
      _salesController.add(_sales);
    });
  }

  @override
  void dispose() {
    _salesController.close();
  }
}
