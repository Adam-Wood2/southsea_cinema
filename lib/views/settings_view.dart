import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/models/user_settings.dart';
import 'package:southsea_cinema/widgets/square_button.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
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

    final UserSettings settings = UserSettings(
        address: address,
        email: email,
        patronNumber: patronNumber,
        receiveNewsletter: _receiveNewsletter);
    setState(() {
      _confirmationMessage = "Settings saved";
    });
  }

  void clearText(TextEditingController controller) {
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text(appTitle)),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Customer Profile",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 20),
              const Text("Address",
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
              TextField(
                controller: _addressController,
                maxLines: 3,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter your current home address",
                    suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () => clearText(_addressController))),
              ),
              const SizedBox(
                height: 12,
              ),
              const Text("Email",
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
              TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter your email address",
                    suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () => clearText(_emailController)),
                  )),
              const SizedBox(height: 12),
              const Text("Patron Number",
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
              TextField(
                controller: _patronNumberController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter your patron number",
                    suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () => clearText(_emailController))),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Recieve news by email"),
                  Switch(
                      value: _receiveNewsletter,
                      onChanged: (bool value) {
                        setState(() {
                          _receiveNewsletter = value;
                        });
                      })
                ],
              ),
              Row(
                spacing: 10,
                children: [
                  SquareButton(
                      label: "CANCEL", onPressed: () => Navigator.pop(context)),
                  SquareButton(label: "SAVE SETTINGS", onPressed: _saveSettings)
                ],
              ),
              if (_confirmationMessage.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(_confirmationMessage)
              ]
            ])));
  }
}
