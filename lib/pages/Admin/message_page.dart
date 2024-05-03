import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:demofb/models/message.dart';
import 'package:demofb/services/message_service.dart';
import 'package:demofb/models/category.dart';
import 'package:demofb/services/category_service.dart';
import '../login.dart';
import 'AdminCategoryList.dart';
import 'messageList_page.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({Key? key}) : super(key: key);

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _objectController = TextEditingController();
  Uint8List? _imageData;
  final MessageService _messageService = MessageService();
  final CategoryService _categoryService = CategoryService();
  List<Category> _categories = [];
  List<Category> _selectedCategories = [];
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final categories = await _categoryService.getCategories().first;
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Future<void> _addMessage() async {
    final body = _bodyController.text.trim();
    final object = _objectController.text.trim();

    if (_selectedCategories.isEmpty || body.isEmpty || object.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please fill in all fields',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[800],
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    final newMessage = Message(
      id: '',
      categories: _selectedCategories.map((category) => category.id).toList(),
      body: body,
      object: object,
      imageData: _imageData,
      createdAt: DateTime.now(),
    );

    try {
      await _messageService.addMessage(newMessage);
      _bodyController.clear();
      _objectController.clear();
      setState(() {
        _imageData = null;
        _selectedCategories.clear();
      });
      Fluttertoast.showToast(
        msg: 'Message added',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[800],
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      print('Error adding message: $e');
    }
  }

  Future<void> _getImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageData = Uint8List.fromList(bytes);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Message', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.green],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.grey[200],
      body: Container(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16),
                Card(
                  surfaceTintColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add a New Message',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),
                        Card(
                          surfaceTintColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: BorderSide(color: _isExpanded ? Colors.blue : Colors.grey),                           ),
                          elevation: 1,
                          child: ExpansionTile(
                            title: Text(
                              'Categories',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onExpansionChanged: (expanded) {
                              setState(() {
                                _isExpanded = expanded;
                              });
                            },
                            children: [
                              SizedBox(height: 8),
                              Wrap(
                                children: _categories.map((category) {
                                  return CheckboxListTile(
                                    title: Text(category.name),
                                    value: _selectedCategories.contains(category),
                                    onChanged: (bool? value) {
                                      setState(() {
                                        if (value != null && value) {
                                          _selectedCategories.add(category);
                                        } else {
                                          _selectedCategories.remove(category);
                                        }
                                      });
                                    },
                                    controlAffinity: ListTileControlAffinity.leading,
                                    activeColor: Colors.blue,
                                    checkColor: Colors.white,
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 16),
                        TextField(
                          controller: _objectController,
                          decoration: InputDecoration(
                            labelText: 'Object',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue, width: 2.0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _bodyController,
                          decoration: InputDecoration(
                            labelText: 'Body',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue, width: 2.0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        _imageData != null
                            ? Image.memory(
                          _imageData!,
                          height: 200,
                        )
                            : Container(),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _getImage,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.image),
                              SizedBox(width: 8),
                              Text('Pick Image'),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Color(0xFF299AD4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _addMessage,
                          child: Text('Add Message'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Color(0xFF299AD4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MessageListPage()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Text('View Messages'),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xFF3EA685),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            Container(
              height: 150,
              child: CustomPaint(
                painter: WavePainter(),

                child: Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        'ISI',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.category),
              title: Text('Categories'),
              onTap: () {
                Navigator.push(
                    context,
                MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.create),
              title: Text('Create Message'),
              onTap: () {
                // Navigate to Message Page
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.message),
              title: Text('Messages'),
              onTap: () {
                // Navigate to Message List Page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MessageListPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF4267B2),
          Color(0xFF66D8A4)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path()
      ..lineTo(0, size.height * 0.9)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height,
        size.width * 0.5,
        size.height * 0.9,
      )
      ..quadraticBezierTo(
        size.width * 0.7,
        size.height * 0.8,
        size.width,
        size.height * 0.9,
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
