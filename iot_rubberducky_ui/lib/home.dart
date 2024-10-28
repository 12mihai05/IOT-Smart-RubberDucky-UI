import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // Import Dio package
import 'saves.dart';
import 'save_script.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController _inputController = TextEditingController();
    final Dio dio = Dio(); // Create an instance of Dio
    const String baseUrl = "http://192.168.127.66:8080"; // Define the base URL

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 19, 19, 19),
      appBar: AppBar(
        title: const Text("Home Page"),
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
                "Home",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 24), // Spacing between title and input field

              // Multiline TextField (Text Box)
              Container(
                constraints: const BoxConstraints(maxWidth: 400),
                width: double.infinity,
                child: TextField(
                  controller: _inputController,
                  cursorColor: Colors.orange, // Set cursor color to orange
                  maxLines: 8, // Set the maximum number of lines to 8
                  decoration: InputDecoration(
                    labelText: "Enter your script",
                    labelStyle: const TextStyle(color: Colors.white), // Default label text color
                    floatingLabelStyle: const TextStyle(color: Colors.orange), // Label color when focused
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white), // White border
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white), // White border when enabled
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange, width: 2), // Orange border when focused
                    ),
                  ),
                  style: const TextStyle(color: Colors.white), // Input text color
                ),
              ),

              const SizedBox(height: 24), // Spacing between input field and buttons

              // Button row
              Row(
                mainAxisSize: MainAxisSize.min, // Minimize the size of the row
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
                      backgroundColor: Colors.orange, // Button color
                      foregroundColor: Colors.white, // Text color
                    ),
                    child: const Text("Save"), // Button text
                  ),
                  const SizedBox(width: 16), // Gap between buttons
                  // Execute button
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        // Retrieve the script from the input field
                        final scriptContent = _inputController.text;

                        // Prepare the request data
                        final data = scriptContent; // Use script content directly

                        // Send the POST request to the execute endpoint
                        final response = await dio.post(
                          "$baseUrl/execute",
                          data: data,
                          options: Options(
                            headers: {"Content-Type": "text/plain"}, // Set header for plain text
                          ),
                        );

                        // Check the response
                        if (response.statusCode == 200) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Script executed successfully: ${response.data}")),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Execution failed: ${response.statusCode}")),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $e")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange, // Button color
                      foregroundColor: Colors.white, // Text color
                    ),
                    child: const Text("Execute"), // Button text
                  ),
                ],
              ),
              const SizedBox(height: 30),
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
                  minimumSize: Size(150, 50),
                ),
                child: const Text(
                  "Saves",
                  style: TextStyle(
                    fontSize: 16, // Font size
                    fontWeight: FontWeight.bold, // Font weight (bold)
                    color: Colors.white, // Text color
                  ),
                ), // Button text
              ),
            ],
          ),
        ),
      ),
    );
  }
}
