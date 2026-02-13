import 'package:cloud_firestore/cloud_firestore.dart';

class PatientProfile {
  final String id;
  final String name;
  final int age;
  final String condition;
  final List<String> deviceIds;

  PatientProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.condition,
    required this.deviceIds,
  });

  factory PatientProfile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return PatientProfile(
      id: doc.id,
      name: data['name'] as String? ?? '',
      age: (data['age'] as num?)?.toInt() ?? 0,
      condition: data['condition'] as String? ?? '',
      deviceIds: (data['device_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'condition': condition,
      'device_ids': deviceIds,
    };
  }
}

