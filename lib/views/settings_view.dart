import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/models/user_settings.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';
import 'package:southsea_cinema/widgets/square_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String prefAddress = "user_address";
const String prefEmail = "user_email";
const String prefPatronNumber = "user_patron_number";
const String prefNewsletter = "user_newsletter";

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

  Future<void> _loadSettings() async {
    final SharedPreferencesAsync prefs = SharedPreferencesAsync();
    final String? savedAddress = await prefs.getString(prefAddress);
    final String? savedEmail = await prefs.getString(prefEmail);
    final String? savedPatronNumber = await prefs.getString(prefPatronNumber);
    final bool? savedNewsletter = await prefs.getBool(prefNewsletter);

    String address = "";
    if (savedAddress != null) {
      address = savedAddress;
    }

    String email = "";
    if (savedEmail != null) {
      email = savedEmail;
    }

    String patronNumber = "";
    if (savedPatronNumber != null) {
      patronNumber = savedPatronNumber;
    }

    bool newsletter = false;
    if (savedNewsletter != null) {
      newsletter = savedNewsletter;
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _addressController.text = address;
      _emailController.text = email;
      _patronNumberController.text = patronNumber;
      _receiveNewsletter = newsletter;
    });
  }

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController();
    _emailController = TextEditingController();
    _patronNumberController = TextEditingController();
    _loadSettings();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _emailController.dispose();
    _patronNumberController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    final String address = _addressController.text.trim();
    final String email = _emailController.text.trim();
    final String patronNumber = _patronNumberController.text.trim();

    final SharedPreferencesAsync prefs = SharedPreferencesAsync();
    await prefs.setString(prefAddress, address);
    await prefs.setString(prefEmail, email);
    await prefs.setString(prefPatronNumber, patronNumber);
    await prefs.setBool(prefNewsletter, _receiveNewsletter);

    final UserSettings settings = UserSettings(
        address: address,
        email: email,
        patronNumber: patronNumber,
        receiveNewsletter: _receiveNewsletter);

    if (!mounted) {
      return;
    }
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
        drawer: NavDrawer(),
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
                        onPressed: () => clearText(_patronNumberController))),
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
