import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'home.dart';

class Saves extends StatelessWidget {
  const Saves({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    // TextEditingController for device name
    final TextEditingController _deviceController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Scripts"),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Container(
        color: const Color.fromARGB(255, 19, 19, 19),
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: user == null
            ? Center(
                child: const Text(
                  "No user logged in",
                  style: TextStyle(color: Colors.white),
                ),
              )
            : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('Saves')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: const Text(
                        "No saved scripts found.",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final scripts = snapshot.data!.docs;

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // Device TextField
                        Container(
                          constraints: const BoxConstraints(maxWidth: 400),
                          width: double.infinity,
                          child: TextField(
                            controller: _deviceController,
                            cursorColor: Colors.orange,
                            decoration: InputDecoration(
                              labelText: "Enter device",
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
                        ),
                        const SizedBox(height: 16),

                        // Build containers for each script
                        ...scripts.map((doc) {
                          final title = doc['title'] ?? 'No Title';
                          final script = doc['script'] ?? 'No Script';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16.0),
                            constraints: const BoxConstraints(
                              minWidth: 500,
                              minHeight: 100,
                            ),
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  script,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const SizedBox(height: 25.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        final deviceName = _deviceController.text.trim();

                                        if (deviceName.isEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("Please enter a device name")),
                                          );
                                          return;
                                        }

                                        try {
                                          // Firebase Realtime Database reference for commands
                                          DatabaseReference ref = FirebaseDatabase.instance
                                              .ref("devices/$deviceName/commands");

                                          await ref.set({
                                            "command": script,
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
                                        backgroundColor: const Color.fromARGB(255, 19, 19, 19),
                                      ),
                                      child: const Text("Execute", style: TextStyle(color: Colors.orange)),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        // Show dialog to edit the script
                                        TextEditingController editController = TextEditingController(text: script);
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              backgroundColor: const Color.fromARGB(255, 19, 19, 19), // Black background
                                              title: const Text(
                                                "Edit Script",
                                                style: TextStyle(color: Colors.white), // White text
                                              ),
                                              content: TextField(
                                                controller: editController,
                                                maxLines: 5,
                                                style: const TextStyle(color: Colors.white), // White text
                                                decoration: const InputDecoration(
                                                  hintText: "Edit script here",
                                                  hintStyle: TextStyle(color: Colors.orange), // Orange hint text
                                                  focusedBorder: UnderlineInputBorder(
                                                    borderSide: BorderSide(color: Colors.orange), // Orange border
                                                  ),
                                                  enabledBorder: UnderlineInputBorder(
                                                    borderSide: BorderSide(color: Colors.white), // White border
                                                  ),
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop(); // Close dialog
                                                  },
                                                  child: const Text("Cancel", style: TextStyle(color: Colors.orange)), // Orange text
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    // Update script in Firestore
                                                    await FirebaseFirestore.instance
                                                        .collection('users')
                                                        .doc(user.uid)
                                                        .collection('Saves')
                                                        .doc(doc.id)
                                                        .update({'script': editController.text});

                                                    Navigator.of(context).pop(); // Close dialog
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(
                                                        content: Text("Script updated successfully"),
                                                      ),
                                                    );
                                                  },
                                                  child: const Text("Save", style: TextStyle(color: Colors.orange)), // Orange text
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue, // Color for edit button
                                      ),
                                      child: const Text("Edit", style: TextStyle(color: Colors.white)),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        // Delete the specific script
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(user.uid)
                                            .collection('Saves')
                                            .doc(doc.id)
                                            .delete();

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("Script deleted successfully"),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text("Delete", style: TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),

                        const SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to Home
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const Home()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(180, 50),
                            backgroundColor: Colors.orange,
                          ),
                          child: const Text("Back to Home", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
