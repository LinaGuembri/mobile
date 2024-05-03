import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shimmer/shimmer.dart';

import '../login.dart';
import '../../services/message_service.dart';
import '../../services/category_service.dart';
import 'studentSubscription_page.dart';

class StudentMessagesPage extends StatefulWidget {
  @override
  _StudentMessagesPageState createState() => _StudentMessagesPageState();
}

class _StudentMessagesPageState extends State<StudentMessagesPage> with SingleTickerProviderStateMixin {
  late User _currentUser;
  late List<String> _subscribedCategories = [];
  late List<String> _filteredMessageIds = [];
  final MessageService messageService = MessageService();
  final CategoryService categoryService = CategoryService();

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      setState(() {
        _currentUser = currentUser;
        _subscribedCategories = List<String>.from(userDoc.get('categories') ?? []);
      });
      _filterMessagesByCategories();
    }
  }

  Future<void> _filterMessagesByCategories() async {
    final allMessages = await FirebaseFirestore.instance.collection('messages').get().then((snapshot) => snapshot.docs);
    final filteredMessages = allMessages.where((message) {
      final List<dynamic> categories = message.get('categories') ?? [];
      return categories.any((category) => _subscribedCategories.contains(category));
    }).toList();
    setState(() {
      _filteredMessageIds = filteredMessages.map((message) => message.id).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages', style: TextStyle(color: Colors.white)),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Recent Messages',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('messages').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                final messages = snapshot.data!.docs;
                final filteredMessages = messages.where((message) => _filteredMessageIds.contains(message.id)).toList();
                return ListView.builder(
                  itemCount: filteredMessages.length,
                  itemBuilder: (context, index) {
                    final message = filteredMessages[index];
                    final List<dynamic> categories = message.get('categories') ?? [];
                    final List<Future<String>> categoryNames = categories.map((categoryId) => categoryService.getCategoryName(categoryId)).toList();
                    final DateTime createdAt = (message.get('createdAt') as Timestamp).toDate();
                    final String body = message.get('body');
                    final String object = message.get('object');
                    final Uint8List? imageData = message.get('imageData') != null ? base64Decode(message.get('imageData')) : null;
                    return Card(
                      color: Colors.white,
                      elevation: 4,
                      surfaceTintColor: Colors.white,
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                      child: ExpansionTile(
                        title: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Text(
                              'ISI',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          title: FutureBuilder<String>(
                            future: Future.delayed(Duration(seconds: 2), () => object),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    height: 16,
                                    width: double.infinity,
                                    color: Colors.white,
                                  ),
                                );
                              }
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }
                              return Text(
                                snapshot.data!,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              );
                            },
                          ),
                          subtitle: FutureBuilder<List<String>>(
                            future: Future.wait(categoryNames),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    height: 16,
                                    width: double.infinity,
                                    color: Colors.white,
                                  ),
                                );
                              }
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }
                              return Text(
                                snapshot.data!.join(', '),
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey[700],
                                ),
                              );
                            },
                          ),
                          trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${createdAt.day}/${createdAt.month}/${createdAt.year}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                '${createdAt.hour}:${createdAt.minute}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ListTile(
                              title: Text(
                                'Body:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(body),
                            ),
                          ),
                          if (imageData != null)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  imageData,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => StudentSubscriptionPage()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.message,
              color: Colors.blue,
               ),
              onPressed: () {
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
