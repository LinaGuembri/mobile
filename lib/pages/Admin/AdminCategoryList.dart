import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../models/category.dart';
import '../../services/category_service.dart';
import '../login.dart';
import 'messageList_page.dart';
import 'message_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CategoryService _categoryService = CategoryService();
  final TextEditingController _categoryNameController = TextEditingController();

  late List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final categories = await _categoryService.getCategories().first;
    setState(() {
      _categories = categories;
    });
  }

  Future<void> _deleteCategory(Category category) async {
    await _categoryService.deleteCategory(category.id);
    _fetchCategories();
  }

  Future<void> _addCategory() async {
    final categoryName = _categoryNameController.text.trim();
    if (categoryName.isNotEmpty) {
      final newCategory = Category(id: 'temp_id', name: categoryName);
      await _categoryService.addCategory(newCategory);
      _categoryNameController.clear();
      _fetchCategories();

      Fluttertoast.showToast(
        msg: 'Category: $categoryName added',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[800],
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Widget _title() {
    return const Text(
      'Categories',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3BA491) ),
    );
  }

  Widget _buildCategoriesTable() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        elevation: 0,
        margin: EdgeInsets.all(10),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (var category in _categories) ...[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          category.name,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteCategory(category),
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.grey),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories', style: TextStyle(color: Colors.white)),
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
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.create),
              title: Text('Create Message'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MessagePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.message),
              title: Text('Messages'),
              onTap: () {

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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Card(
              surfaceTintColor: Colors.white,
              elevation: 4,
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Add a new category',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Color(0xFF3BA491) ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        controller: _categoryNameController,
                        decoration: InputDecoration(
                          hintText: 'Enter category name',
                          filled: true,
                          fillColor: Colors.grey[200],
                          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Center(
                      child: Container(
                        width: 100,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF2196F3), Color(0xFF00BCD4)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: ElevatedButton(
                          onPressed: _addCategory,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 3, horizontal: 12),
                            child: Text(
                              'Add',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            elevation: 0, backgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              surfaceTintColor: Colors.white,
              elevation: 4,
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _title(),
                    SizedBox(height: 10),
                    _buildCategoriesTable(),
                  ],
                ),
              ),
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
        colors: [Color(0xFF4267B2), Color(0xFF66D8A4)],
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
