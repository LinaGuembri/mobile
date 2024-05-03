import 'dart:typed_data';
import 'package:demofb/pages/Admin/message_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/category.dart';
import '../../services/category_service.dart';
import '../login.dart';
import '../../models/message.dart';
import '../../services/message_service.dart';
import 'AdminCategoryList.dart';
import 'popup.dart';

class MessageListPage extends StatefulWidget {
  @override
  _MessageListPageState createState() => _MessageListPageState();
}

class _MessageListPageState extends State<MessageListPage> {
  final MessageService messageService = MessageService();
  final CategoryService categoryService = CategoryService();


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
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: EdgeInsets.only(top: 15),
        child: StreamBuilder<List<Message>>(
          stream: messageService.getMessages(),
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
            final messages = snapshot.data ?? [];
            return ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return FutureBuilder<List<String>>(
                  future: Future.wait(
                      message.categories.map((categoryId) => categoryService.getCategoryName(categoryId))),
                  builder: (context, categorySnapshot) {
                    if (categorySnapshot.connectionState == ConnectionState.waiting) {
                      return _buildShimmerMessage();
                    }
                    if (categorySnapshot.hasError) {
                      return Text('Error: ${categorySnapshot.error}');
                    }
                    final categoryNames = categorySnapshot.data ?? [];
                    final categoryName = categoryNames.join(', ');
                    return Card(
                      elevation: 4,
                      surfaceTintColor: Colors.white,
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(
                            'ISI',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(message.object),
                        subtitle: Text(categoryName),
                        trailing: Text(
                          '${message.createdAt.day}/${message.createdAt.month}/${message.createdAt.year} ${message.createdAt.hour}:${message.createdAt.minute}',
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                message.body,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          if (message.imageData != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: MemoryImage(message.imageData!),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                InkWell(
                                  onTap: () {
                                    _showUpdateDialog(context, message);
                                  },
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                    size: 25,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    messageService.deleteMessage(message.id);
                                  },
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 25,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
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
                );              },
            ),
            ListTile(
              leading: Icon(Icons.create),
              title: Text('Create Message'),
              onTap: () {
                // Navigate to Message Page
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
                Navigator.pop(context);

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

  Widget _buildImageWidget(Uint8List? imageData) {
    if (imageData != null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: MemoryImage(imageData),
            ),
          ),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget _buildShimmerMessage() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        elevation: 4,
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey[300],
            child: Icon(Icons.person, color: Colors.white),
          ),
          title: Container(
            width: double.infinity,
            height: 15,
            color: Colors.grey[300],
          ),
          subtitle: Container(
            width: double.infinity,
            height: 10,
            color: Colors.grey[300],
          ),
          trailing: Container(
            width: 100,
            height: 15,
            color: Colors.grey[300],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                height: 50,
                color: Colors.grey[300],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 100,
                height: 100,
                color: Colors.grey[300],
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text('Update'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateDialog(BuildContext context, Message message) {
    TextEditingController objectController = TextEditingController(text: message.object);
    TextEditingController bodyController = TextEditingController(text: message.body);
    List<String> selectedCategoryIds = List.from(message.categories);
    List<Category> selectedCategories = [];
    Uint8List? localImageData;

    final CategoryService categoryService = CategoryService();
    Future<List<Category>> categoriesFuture = categoryService.getCategoriesF();

    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<List<Category>>(
          future: categoriesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return AlertDialog(
                surfaceTintColor: Colors.white,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                content: Text(
                  'Error loading categories: ${snapshot.error.toString()}',
                  style: TextStyle(color: Colors.red),
                ),
              );
            }

            List<Category> allCategories = snapshot.data ?? [];
            selectedCategories = allCategories.where((cat) => selectedCategoryIds.contains(cat.id)).toList();

            return AlertDialog(
              surfaceTintColor: Colors.white,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              title: Text('Update Message', style: TextStyle(color: Color(0xFF3BA491) ),),
              content: SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Update the message details:', style: TextStyle(color: Colors.black)),
                    SizedBox(height: 10),
                    TextField(
                      controller: objectController,
                      decoration: InputDecoration(
                        labelText: 'Object',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: bodyController,
                      decoration: InputDecoration(
                        labelText: 'Body',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 10),
                    _buildImageWidget(localImageData),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final picker = ImagePicker();
                        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          final bytes = await pickedFile.readAsBytes();
                          setState(() {
                            localImageData = Uint8List.fromList(bytes);
                          });
                        }
                      },
                      child: Text('Choose Image', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final List<Category>? updatedCategories = await showMultiSelectPopup(
                          context,
                          allCategories,
                          selectedCategories,
                        );
                        if (updatedCategories != null) {
                          setState(() {
                            selectedCategories = updatedCategories;
                            selectedCategoryIds = updatedCategories.map((c) => c.id).toList();
                          });
                        }
                      },
                      child: Text('Select Categories', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: selectedCategories.map((cat) {
                        return Chip(
                          label: Text(cat.name, style: TextStyle(color: Colors.white)),
                          backgroundColor: Colors.grey,
                          deleteIconColor: Colors.white,
                          onDeleted: () {
                            setState(() {
                              selectedCategories.remove(cat);
                              selectedCategoryIds.remove(cat.id);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel', style: TextStyle(color: Colors.black)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Message updatedMessage = Message(
                      id: message.id,
                      categories: selectedCategoryIds,
                      object: objectController.text,
                      body: bodyController.text,
                      imageData: localImageData ?? message.imageData,
                      createdAt: message.createdAt,
                    );
                    messageService.updateMessage(updatedMessage);
                    Navigator.of(context).pop();
                  },
                  child: Text('Update', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

Future<List<Category>?> showMultiSelectPopup(BuildContext context, List<Category> options, List<Category> selectedCategories) {
  return Navigator.of(context).push(MultiSelectPopup<Category>(
    options: options,
    initialValue: List.from(selectedCategories),
    itemBuilder: (BuildContext context, Category category, bool isSelected) {
      return ListTile(
        title: Text(category.name),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: Colors.green)
            : Icon(Icons.radio_button_unchecked),
        onTap: () {
          if (isSelected) {
            selectedCategories.remove(category);
          } else {
            selectedCategories.add(category);
          }
          Navigator.of(context).pop(selectedCategories);
        },
      );
    },
  ));
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
