import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/patient_profile.dart';
import '../services/firebase_service.dart';

class PatientProfileScreen extends StatefulWidget {
  static const routeName = '/patient-profile';

  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _conditionController = TextEditingController();
  final _deviceIdsController = TextEditingController();

  bool _loading = true;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final firebase = context.read<FirebaseService>();
    final profile = await firebase.getPatientProfile();
    if (!mounted) return;
    if (profile != null) {
      _nameController.text = profile.name;
      _ageController.text = profile.age.toString();
      _conditionController.text = profile.condition;
      _deviceIdsController.text = profile.deviceIds.join(', ');
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final firebase = context.read<FirebaseService>();
    final deviceIds = _deviceIdsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final profile = PatientProfile(
      id: firebase.auth.currentUser?.uid ?? '',
      name: _nameController.text.trim(),
      age: int.tryParse(_ageController.text.trim()) ?? 0,
      condition: _conditionController.text.trim(),
      deviceIds: deviceIds,
    );
    await firebase.upsertPatientProfile(profile);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved')),
    );
  }

  Future<void> _deleteProfile() async {
    final firebase = context.read<FirebaseService>();
    await firebase.deletePatientProfile();
    if (!mounted) return;
    _nameController.clear();
    _ageController.clear();
    _conditionController.clear();
    _deviceIdsController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Profile'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Age'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _conditionController,
                      decoration: const InputDecoration(
                        labelText: 'Condition',
                        hintText: 'e.g. Parkinson’s Disease',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _deviceIdsController,
                      decoration: const InputDecoration(
                        labelText: 'Device IDs',
                        hintText: 'Comma separated (e.g. LEFT123, RIGHT456)',
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saving ? null : _saveProfile,
                            child: _saving
                                ? const CircularProgressIndicator()
                                : const Text('Save'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: _deleteProfile,
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

