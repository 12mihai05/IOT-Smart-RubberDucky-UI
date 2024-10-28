import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart'; // Import Dio package for HTTP requests
import 'home.dart';

class Saves extends StatelessWidget {
  const Saves({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;
    final Dio dio = Dio(); // Create an instance of Dio
    const String baseUrl = "http://192.168.127.66:8080"; // Define the base URL

    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Scripts"),
        centerTitle: true,
        backgroundColor: Colors.orange, // App bar color
      ),
      body: Container(
        color: const Color.fromARGB(255, 19, 19, 19), // Background color of the body
        width: double.infinity, // Full width
        height: double.infinity, // Full height
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
                    .orderBy('timestamp', descending: true) // Order by timestamp
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
                        // Build containers for each script
                        ...scripts.map((doc) {
                          final title = doc['title'] ?? 'No Title';
                          final script = doc['script'] ?? 'No Script';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16.0),
                            constraints: const BoxConstraints(
                              minWidth: 500, // Set the minimum width here
                              minHeight: 100, // Set a minimum height
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
                                        try {
                                          // Send the script to the server
                                          final response = await dio.post(
                                            "$baseUrl/execute",
                                            data: script,
                                            options: Options(
                                              headers: {
                                                "Content-Type": "text/plain"
                                              }, // Set header for plain text
                                            ),
                                          );

                                          // Check the response
                                          if (response.statusCode == 200) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "Script executed successfully: ${response.data}",
                                                ),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "Execution failed: ${response.statusCode}",
                                                ),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("Error: $e")),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color.fromARGB(255, 19, 19, 19),
                                      ),
                                      child: const Text("Execute",
                                          style: TextStyle(color: Colors.orange)),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        // Delete the specific script
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(user.uid)
                                            .collection('Saves')
                                            .doc(doc.id) // Use document ID to delete
                                            .delete();

                                        // Show a confirmation message
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("Script deleted successfully"),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red, // Set color for delete button
                                      ),
                                      child: const Text("Delete",
                                          style: TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),

                        // Back to Home button
                        const SizedBox(height: 16.0), // Space above the button
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
                            backgroundColor: Colors.orange, // Button color
                          ),
                          child: const Text("Back to Home",
                              style: TextStyle(color: Colors.white)), // Button text color
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
