import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';
import 'home.dart'; // Add this import statement

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  final FirebaseAuth _auth = FirebaseAuth.instance; // Initialize FirebaseAuth

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Register the user using email and password
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        // Navigate to home page upon successful registration
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())), // Show error message
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 19, 19, 19),
      appBar: AppBar(
        title: const Text("Register"),
        centerTitle: true,
        backgroundColor: Colors.orange, // App bar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Register",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 50),

                  // Username field
                  _buildTextFormField(
                    controller: _usernameController,
                    labelText: "Username",
                    prefixIcon: Icons.person,
                    isPassword: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your username";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email field
                  _buildTextFormField(
                    controller: _emailController,
                    labelText: "Email",
                    prefixIcon: Icons.email,
                    isPassword: false,
                    validator: (value) {
                      if (value == null || !value.contains('@')) {
                        return "Please enter a valid email";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  _buildTextFormField(
                    controller: _passwordController,
                    labelText: "Password",
                    prefixIcon: Icons.lock,
                    isPassword: true,
                    obscureText: _obscurePassword,
                    toggleObscureText: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password field
                  _buildTextFormField(
                    controller: _confirmPasswordController,
                    labelText: "Confirm Password",
                    prefixIcon: Icons.lock,
                    isPassword: true,
                    obscureText: _obscurePassword,
                    toggleObscureText: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _register, // Call the register method
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text("Register", style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?", style: TextStyle(color: Colors.white)),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const Login()),
                          );
                        },
                        child: const Text("Login", style: TextStyle(color: Colors.orange)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Build TextFormField helper function
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    required bool isPassword,
    bool obscureText = false,
    void Function()? toggleObscureText,
    String? Function(String?)? validator,
  }) {
    return Container(
      constraints: BoxConstraints(maxWidth: 400),
      width: double.infinity,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        cursorColor: Colors.orange,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.white),
          prefixIcon: Icon(prefixIcon, color: Colors.white),
          floatingLabelStyle: const TextStyle(color: Colors.orange),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.orange),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.orange),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white,
                  ),
                  onPressed: toggleObscureText,
                )
              : null,
        ),
        style: const TextStyle(color: Colors.white),
        validator: validator,
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
