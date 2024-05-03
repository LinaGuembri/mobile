import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demofb/models/message.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _messagesCollection =
  FirebaseFirestore.instance.collection('messages');

  Stream<List<Message>> getMessages() {
    return _messagesCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      Uint8List? imageData;
      if (doc['imageData'] != null) {
        imageData = base64Decode(doc['imageData']);
      }
      return Message(
        id: doc.id,
        categories: List<String>.from(doc['categories']),
        body: doc['body'],
        object: doc['object'],
        imageData: imageData ?? Uint8List(0),
        createdAt: (doc['createdAt'] as Timestamp).toDate(),
      );
    }).toList());
  }

  Future<void> addMessage(Message message) async {
    try {
      String? imageData;
      if (message.imageData != null) {
        imageData = base64Encode(message.imageData!);
      }

      await _messagesCollection.add({
        'categories': message.categories,
        'body': message.body,
        'object': message.object,
        'imageData': imageData,
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error adding message: $e');
      throw e;
    }
  }

  Future<void> updateMessage(Message message) async {
    try {
      String? imageData;
      if (message.imageData != null) {
        imageData = base64Encode(message.imageData!);
      }

      await _messagesCollection.doc(message.id).update({
        'categories': message.categories,
        'body': message.body,
        'object': message.object,
        'imageData': imageData,
        'createdAt': Timestamp.now(),

      });
    } catch (e) {
      print('Error updating message: $e');
      throw e;
    }
  }

  Future<void> deleteMessage(String messageId) async {
    await _messagesCollection.doc(messageId).delete();
  }
}
