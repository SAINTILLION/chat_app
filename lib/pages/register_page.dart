import 'package:chat_app/components/cirular_progress_indicator.dart';
import 'package:chat_app/components/my_text_field.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/my_button.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //text controlllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _obscurePassword_1 = true;
  bool _obscurePassword_2 = true;



  // sign up user
  void signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match"),
        ),
      );
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    Circular_ProgressIndicator(context);
    try {
      await authService.signUpWithEmailandPassword(
          emailController.text, passwordController.text
        );
        Navigator.pop(context); //CLOSE LODING DIALOG
    } catch (e) {
      Navigator.pop(context); //CLOSE LODING DIALOG
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                // Logo
                Icon(
                  Icons.message,
                  size: 100,
                  color: Colors.grey[800],
                ),

                // create an account message
                const Text(
                  "Let's create an account for you",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 25),

                // email textfield
                MyTextField(
                  controller: emailController,
                  hintText: "Email",
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // Password field with toggle
                MyTextField(
                  controller: passwordController,
                  hintText: "Password",
                  obscureText: _obscurePassword_1,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword_1
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword_1 = !_obscurePassword_1;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 10),

                //  confirm Password field with toggle
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: "Password",
                  obscureText: _obscurePassword_2,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword_2
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword_2 = !_obscurePassword_2;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 50),

                //sign up button
                MyButton(onTap: signUp, text: "Sign Up"),

                const SizedBox(height: 50),

                // not a member? register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Aready a member?"),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: widget.onTap,
                      child: const Text(
                        "Login Now",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
