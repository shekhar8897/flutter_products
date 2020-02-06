import 'package:flutter/material.dart';

class Product{
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final  bool isFavorite;
  final String userEmail;
  final String userId;

  Product
      (
        {
          @required this.id,
          @required this.title,
          @required this.description,
          @required this.price,
          @required this.imageUrl,
          this.isFavorite=false,
          @required this.userEmail,
          @required this.userId
        }
      );
}
