import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../login.dart';
import 'studentMessage_page.dart';

class StudentSubscriptionPage extends StatefulWidget {
  @override
  _StudentSubscriptionPageState createState() => _StudentSubscriptionPageState();
}

class _StudentSubscriptionPageState extends State<StudentSubscriptionPage> {
  late List<DocumentSnapshot> _categories = [];
  User? _currentUser;
  late List<String> _subscribedCategories = [];
  late List<Future<String>> _categoryNames = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _getCurrentUser();
  }

  Future<void> _fetchCategories() async {
    final categories = await FirebaseFirestore.instance.collection('categories').get();
    setState(() {
      _categories = categories.docs;
    });
  }

  Future<void> _getCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      setState(() {
        _currentUser = currentUser;
        _subscribedCategories = List<String>.from(userDoc.get('categories'));
        _categoryNames = _subscribedCategories.map((categoryId) => getCategoryName(categoryId)).toList();
      });
    }
  }

  Future<String> getCategoryName(String categoryId) async {
    final categoryDoc = await FirebaseFirestore.instance.collection('categories').doc(categoryId).get();
    return categoryDoc.get('name');
  }

  Future<void> _updateUserCategories(List<String> categories) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid);
    await userDoc.update({'categories': categories});
  }

  bool _isSubscribed(String categoryId) {
    return _subscribedCategories.contains(categoryId);
  }

  void _toggleSubscription(String categoryId) {
    setState(() {
      if (_isSubscribed(categoryId)) {
        _subscribedCategories.remove(categoryId);
      } else {
        _subscribedCategories.add(categoryId);
      }
      _categoryNames = _subscribedCategories.map((categoryId) => getCategoryName(categoryId)).toList();
    });

    _updateUserCategories(_subscribedCategories);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: Colors.white)),
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

      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_currentUser != null)
                Text(
                  'Email: ${_currentUser!.email}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

              SizedBox(height: 16),
              Card(
                color: Colors.white,
                elevation: 4,
                surfaceTintColor: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Subscribed Categories:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: _subscribedCategories.length,
                        itemBuilder: (context, index) {
                          return FutureBuilder<String>(
                            future: _categoryNames[index],
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                final categoryName = snapshot.data!;
                                return ListTile(
                                  title: Text(categoryName),
                                  trailing: IconButton(
                                    icon: Icon(Icons.cancel, color: Colors.red),
                                    onPressed: () => _toggleSubscription(_subscribedCategories[index]),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Card(
                color: Colors.white,
                elevation: 4,
                surfaceTintColor: Colors.white,
                child: ExpansionTile(
                  title: Text(
                    'Available Categories:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _categories.isNotEmpty
                            ? _categories.map((category) {
                          final categoryId = category.id;
                          final isSubscribed = _isSubscribed(categoryId);

                          return ListTile(
                            title: FutureBuilder<String>(
                              future: getCategoryName(categoryId),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  final categoryName = snapshot.data!;
                                  return Text(categoryName);
                                }
                              },
                            ),
                            trailing: isSubscribed
                                ? Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            )
                                : Icon(Icons.check_circle_outline),
                            onTap: () => _toggleSubscription(categoryId),
                          );
                        }).toList()
                            : [Center(child: CircularProgressIndicator())],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.settings,
                color: Colors.blue,
              ),
              onPressed: () {
              },
            ),
            IconButton(
              icon: Icon(Icons.message),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => StudentMessagesPage()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
