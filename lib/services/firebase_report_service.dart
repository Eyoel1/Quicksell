import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report_model.dart';

class FirebaseReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> reportProduct(ReportModel report) async {
    final ref = _firestore.collection('reports').doc();
    await ref.set(report.toJson()..['id'] = ref.id);
    return ref.id;
  }
}
