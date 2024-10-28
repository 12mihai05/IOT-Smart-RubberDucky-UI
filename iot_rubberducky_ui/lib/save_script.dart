import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import for authentication
import 'saves.dart';
import 'home.dart'; // Import the Home widget

class SaveScript extends StatelessWidget {
  const SaveScript({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _scriptController = TextEditingController();

    Future<void> _saveToFirestore() async {
      try {
        // Get the current user
        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          // Handle the case when there is no user logged in
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No user logged in")),
          );
          return;
        }

        // Define the document ID as the user's uid
        String userId = user.uid;

        // Access Firestore and add a new document to the user's Saves subcollection
        await FirebaseFirestore.instance
            .collection('users') // Create a users collection
            .doc(userId) // Use the user's uid as the document ID
            .collection('Saves') // Create a Saves subcollection for each user
            .add({
          'title': _titleController.text,
          'script': _scriptController.text,
          'timestamp': FieldValue.serverTimestamp(), // Optional: add a timestamp
        });

        // Show a confirmation message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Script saved successfully")),
        );

        // Clear the input fields
        _titleController.clear();
        _scriptController.clear();
      } catch (e) {
        // Display an error message if saving fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save script: $e")),
        );
      }
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 19, 19, 19),
      appBar: AppBar(
        title: const Text("Save Script"),
        centerTitle: true,
        backgroundColor: Colors.orange, // App bar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Save Script",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 24),

              // Title input field
              Container(
                constraints: const BoxConstraints(maxWidth: 400),
                width: double.infinity,
                child: TextFormField(
                  controller: _titleController,
                  cursorColor: Colors.orange,
                  decoration: InputDecoration(
                    labelText: "Enter script title",
                    labelStyle: const TextStyle(color: Colors.white),
                    floatingLabelStyle: const TextStyle(color: Colors.orange),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange, width: 2), // Orange border when focused
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),

              const SizedBox(height: 16),

              // Script input field (multi-line text box)
              Container(
                constraints: const BoxConstraints(maxWidth: 400),
                width: double.infinity,
                child: TextField(
                  controller: _scriptController,
                  cursorColor: Colors.orange,
                  maxLines: 8, // Set the maximum number of lines to 8
                  decoration: InputDecoration(
                    labelText: "Enter script",
                    labelStyle: const TextStyle(color: Colors.white),
                    floatingLabelStyle: const TextStyle(color: Colors.orange),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange, width: 2), // Orange border when focused
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),

              const SizedBox(height: 16),

              // Button row for Save and View Saves
              Row(
                mainAxisSize: MainAxisSize.min, // Minimize the size of the row
                mainAxisAlignment: MainAxisAlignment.center, // Center the buttons
                children: [
                  // Save button
                  ElevatedButton(
                    onPressed: _saveToFirestore,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange, // Button color
                      foregroundColor: Colors.white, // Text color
                      minimumSize: const Size(100, 50), // Minimum size for the button
                    ),
                    child: const Text("Save"), // Button text
                  ),
                  const SizedBox(width: 16), // Gap between buttons
                  // View Saves button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const Saves()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange, // Button color
                      foregroundColor: Colors.white, // Text color
                      minimumSize: const Size(100, 50), // Minimum size for the button
                    ),
                    child: const Text("View Saves"), // Button text
                  ),
                ],
              ),

              const SizedBox(height: 40), // Spacing between button row and the back button

              // Navigate to Home page button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Home()), // Navigate back to Home
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(150, 50),
                ),
                child: const Text(
                  "Back to Home",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
