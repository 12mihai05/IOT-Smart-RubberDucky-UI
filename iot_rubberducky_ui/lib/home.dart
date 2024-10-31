import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart'; // Import Firebase Realtime Database package
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth package
import 'saves.dart';
import 'save_script.dart';
import 'login.dart'; // Import your login page
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController _scriptController = TextEditingController();
    final TextEditingController _deviceController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 19, 19, 19),
      appBar: AppBar(
        title: const Text("Home Page"),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Home",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 24),

              // Device TextField
              _buildTextField(_deviceController, "Enter device"),
              const SizedBox(height: 16),

              // Script TextField
              _buildScriptTextField(_scriptController),
              const SizedBox(height: 24),

              // Button row
              _buildButtonRow(context, _deviceController, _scriptController),
              const SizedBox(height: 30),

              // Saves button
              _buildSavesButton(context),
              const SizedBox(height: 30),

              // Sign Out button
              _buildSignOutButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      width: double.infinity,
      child: TextField(
        controller: controller,
        cursorColor: Colors.orange,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          floatingLabelStyle: const TextStyle(color: Colors.orange),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange, width: 2),
          ),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildScriptTextField(TextEditingController controller) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      width: double.infinity,
      child: TextField(
        controller: controller,
        cursorColor: Colors.orange,
        maxLines: 8,
        decoration: InputDecoration(
          labelText: "Enter your script",
          labelStyle: const TextStyle(color: Colors.white),
          floatingLabelStyle: const TextStyle(color: Colors.orange),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange, width: 2),
          ),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildButtonRow(BuildContext context, TextEditingController deviceController, TextEditingController scriptController) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Save button
        ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SaveScript()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: const Text("Save"),
        ),
        const SizedBox(width: 16),

        // Execute button
        ElevatedButton(
          onPressed: () async {
            final deviceName = deviceController.text.trim();
            final scriptContent = scriptController.text.trim();

            if (deviceName.isEmpty || scriptContent.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please enter both device name and script")),
              );
              return;
            }

            try {
              // Firebase Realtime Database reference for commands
              DatabaseReference ref = FirebaseDatabase.instance.ref("devices/$deviceName/commands");

              await ref.set({
                "command": scriptContent,
                "timestamp": DateTime.now().millisecondsSinceEpoch ~/ 1000,
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Script executed successfully")),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error: $e")),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: const Text("Execute"),
        ),
      ],
    );
  }

  Widget _buildSavesButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Saves()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        minimumSize: const Size(150, 50),
      ),
      child: const Text(
        "Saves",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
  return ElevatedButton(
    onPressed: () async {
      try {
        await FirebaseAuth.instance.signOut(); // Sign out from Firebase

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Successfully signed out")),
        );

        // Navigate to the Login page directly
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()), // Navigate to the Login page
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error signing out: $e")),
        );
      }
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.red, // Sign out button color
      foregroundColor: Colors.white,
      minimumSize: const Size(150, 50),
    ),
    child: const Text(
      "Sign Out",
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
  );
}
}