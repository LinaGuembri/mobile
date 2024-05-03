import 'package:demofb/pages/Admin/AdminCategoryList.dart';
import 'package:demofb/pages/Admin/messageList_page.dart';
import 'package:demofb/pages/Student/studentMessage_page.dart';
import 'package:demofb/pages/Student/studentSubscription_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'register.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isObscure3 = true;
  bool visible = false;
  final _formkey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _auth = FirebaseAuth.instance;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _animationController.forward();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF247ACC),
              Color(0xFF66D8A4)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 400,
                child: CustomPaint(
                  painter: WavePainter(),
                ),
              ),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 120),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 100.0),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: Colors.transparent,
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Colors.grey,
                      unselectedLabelColor: Colors.white.withOpacity(0.5),
                      labelPadding: EdgeInsets.symmetric(horizontal: 20.0),
                      tabs: [
                        Tab(text: 'Login'),
                        Tab(text: 'Register'),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLogin(),
                      _buildRegister(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogin() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 100 * (1 - _animation.value)),
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
        child: SingleChildScrollView(
          child: Card(
            elevation: 8,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formkey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    TextFormField(
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
                        }
                        if (!RegExp(
                            "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                            .hasMatch(value)) {
                          return "Please enter a valid email";
                        } else {
                          return null;
                        }
                      },
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: passwordController,
                      obscureText: _isObscure3,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[200],
                        hintText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.lock, color: Color(0xFF66D8A4)),
                        suffixIcon: IconButton(
                          icon: Icon(_isObscure3
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _isObscure3 = !_isObscure3;
                            });
                          },
                          color: Color(0xFF66D8A4),
                        ),
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
                      style: TextStyle(fontSize: 16),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: SizedBox(
                        width: 120,
                        child: Center(
                          child: MaterialButton(
                            height: 40,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            onPressed: () {
                              setState(() {
                                visible = true;
                              });
                              signIn(emailController.text,
                                  passwordController.text);
                            },
                            child: Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: visible,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegister() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
      child: SingleChildScrollView(
        child: Card(
          elevation: 8,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Register(),
          ),
        ),
      ),
    );
  }


  void route() {
    User? user = FirebaseAuth.instance.currentUser;
    var kk = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        if (documentSnapshot.get('role') == "Admin") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => StudentMessagesPage(),
            ),
          );
        }
      } else {
        print('Document does not exist on the database');
      }
    });
  }

  void signIn(String email, String password) async {
    if (_formkey.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        route();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          showToast('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          showToast('Wrong password provided for that user.');
        } else {
          showToast('Error: ${e.message}');
        }
      }
    }
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF4267B2), Color(0xFF66D8A4)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path()
      ..lineTo(0, size.height * 0.8)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height,
        size.width * 0.5,
        size.height * 0.8,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.6,
        size.width,
        size.height * 0.8,
      )
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

void main() {
  runApp(MaterialApp(
    home: LoginPage(),
  ));
}
