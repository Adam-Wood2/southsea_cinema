import 'package:flutter/material.dart';
import 'package:southsea_cinema/models/user_settings.dart';

class SettingsView extends StatefulWidget {
  const SettingsView();

  State<SettingsView> createState() {
    return _SettingsViewState();
  }
}

class _SettingsViewState extends State<SettingsView> {

  late TextEditingController _addressController;
  late TextEditingController _emailController;
  late TextEditingController _patronNumberController;
  bool _receiveNewsletter = false;
  String _confirmationMessage = "";

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController();
    _emailController = TextEditingController();
    _patronNumberController = TextEditingController();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _emailController.dispose();
    _patronNumberController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final String address = _addressController.text.trim();
    final String email = _emailController.text.trim();
    final String patronNumber = _patronNumberController.text.trim();

    final UserSettings settings = UserSettings(address: address, email: email, patronNumber: patronNumber, receiveNewsletter: _receiveNewsletter);
    setState(() {
      _confirmationMessage = "Settings saved";
    });
  }

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
