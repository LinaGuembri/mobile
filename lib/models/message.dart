import 'dart:typed_data';

import 'package:flutter/material.dart';

class Message {
  final String id;
  final List<String> categories;
  final String body;
  final String object;
  final Uint8List? imageData;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.categories,
    required this.body,
    required this.object,
    this.imageData,
    required this.createdAt,
  });
}