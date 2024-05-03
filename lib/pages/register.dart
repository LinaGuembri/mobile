import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'login.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();
  bool _isObscure = true;
  bool _isObscure2 = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Register",
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  hintText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.person, color: Color(0xFF66D8A4)),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Name cannot be empty";
                  }
                  return null;
                },
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 50,
              child: TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  hintText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.email, color: Color(0xFF66D8A4)),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Email cannot be empty";
                  } else if (!RegExp(
                      "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                      .hasMatch(value)) {
                    return "Please enter a valid email";
                  }
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 50,
              child: TextFormField(
                controller: passwordController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                    color: Color(0xFF66D8A4),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  hintText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.lock, color: Color(0xFF66D8A4)),
                ),
                validator: (value) {
                  RegExp regex = RegExp(r'^.{6,}$');
                  if (value!.isEmpty) {
                    return "Password cannot be empty";
                  }
                  if (!regex.hasMatch(value)) {
                    return "Please enter a valid password (min. 6 characters)";
                  } else {
                    return null;
                  }
                },
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 50,
              child: TextFormField(
                controller: confirmPasswordController,
                obscureText: _isObscure2,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: Icon(_isObscure2 ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _isObscure2 = !_isObscure2;
                      });
                    },
                    color: Color(0xFF66D8A4),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  hintText: 'Confirm Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.lock, color: Color(0xFF66D8A4)),
                ),
                validator: (value) {
                  if (confirmPasswordController.text != passwordController.text) {
                    return "Passwords do not match";
                  } else {
                    return null;
                  }
                },
              ),
            ),
            SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 70),
              child: SizedBox(
                child: MaterialButton(
                  onPressed: () {
                    signUp(
                      nameController.text,
                      emailController.text,
                      passwordController.text,
                      confirmPasswordController.text,
                    );
                  },
                  child: Text(
                    "Register",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  color: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void signUp(String name, String email, String password,
      String confirmPassword) async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(email: email, password: password);
        postDetailsToFirestore(name, email);

        Fluttertoast.showToast(
          msg: "Registration successful!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } catch (e) {
        if (e is FirebaseAuthException) {
          if (e.code == 'weak-password') {
            Fluttertoast.showToast(
              msg: "The password provided is too weak.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          } else if (e.code == 'email-already-in-use') {
            Fluttertoast.showToast(
              msg: "The account already exists for that email.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          } else {
            Fluttertoast.showToast(
              msg: "Registration failed. Please try again.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }
        } else {
          print(e);
          Fluttertoast.showToast(
            msg: "Registration failed. Please try again.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      }
    }
  }


  void postDetailsToFirestore(String name, String email) async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;

    List<String> categories = [
      'N8L46Jw8ndW2vVaMuR3D'
    ];
    await firebaseFirestore.collection('users').doc(user!.uid).set({
      'name': name,
      'email': email,
      'role': 'Student',
      'categories': categories,
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
}
