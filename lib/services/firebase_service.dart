import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/ble_models.dart';
import '../models/patient_profile.dart';

class FirebaseService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<UserCredential> signIn(String email, String password) {
    return auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() => auth.signOut();

  String? get _patientId => auth.currentUser?.uid;

  /// Patient profile CRUD
  Future<PatientProfile?> getPatientProfile() async {
    final pid = _patientId;
    if (pid == null) return null;
    final doc = await firestore.collection('patients').doc(pid).get();
    if (!doc.exists) return null;
    return PatientProfile.fromDoc(doc);
  }

  Future<void> upsertPatientProfile(PatientProfile profile) async {
    final pid = _patientId;
    if (pid == null) return;
    await firestore.collection('patients').doc(pid).set(profile.toMap());
  }

  Future<void> deletePatientProfile() async {
    final pid = _patientId;
    if (pid == null) return;
    await firestore.collection('patients').doc(pid).delete();
  }

  Future<void> logSensorData(ShoeData data) async {
    final pid = _patientId;
    if (pid == null) return;
    final ts = DateTime.now().millisecondsSinceEpoch.toString();

    await firestore
        .collection('pressure_logs')
        .doc(pid)
        .collection('entries')
        .doc(ts)
        .set({
      'timestamp': DateTime.now(),
      'left_front_pressure': data.left.frontPressure,
      'left_heel_pressure': data.left.heelPressure,
      'right_front_pressure': data.right.frontPressure,
      'right_heel_pressure': data.right.heelPressure,
    });

    await firestore
        .collection('battery_logs')
        .doc(pid)
        .collection('entries')
        .doc(ts)
        .set({
      'timestamp': DateTime.now(),
      'left_battery': data.left.battery,
      'right_battery': data.right.battery,
    });
  }

  Future<void> logAlert({
    required String type,
    required String severity,
    required String message,
  }) async {
    final pid = _patientId;
    if (pid == null) return;
    final ts = DateTime.now().millisecondsSinceEpoch.toString();

    await firestore
        .collection('alerts')
        .doc(pid)
        .collection('entries')
        .doc(ts)
        .set({
      'timestamp': DateTime.now(),
      'type': type,
      'severity': severity,
      'message': message,
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> pressureLogsStream(
    DateTime from,
  ) {
    final pid = _patientId;
    return firestore
        .collection('pressure_logs')
        .doc(pid)
        .collection('entries')
        .where('timestamp', isGreaterThanOrEqualTo: from)
        .orderBy('timestamp')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> batteryLogsStream(
    DateTime from,
  ) {
    final pid = _patientId;
    return firestore
        .collection('battery_logs')
        .doc(pid)
        .collection('entries')
        .where('timestamp', isGreaterThanOrEqualTo: from)
        .orderBy('timestamp')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> alertsStream(
    DateTime from,
  ) {
    final pid = _patientId;
    return firestore
        .collection('alerts')
        .doc(pid)
        .collection('entries')
        .where('timestamp', isGreaterThanOrEqualTo: from)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}


