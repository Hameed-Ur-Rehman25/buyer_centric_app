// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:buyer_centric_app/widgets/price_range_slider.dart';

class PostCreationScreen extends StatefulWidget {
  final String make;
  final String model;
  final String year;
  final String imageUrl;

  PostCreationScreen({
    required this.make,
    required this.model,
    required this.year,
    required this.imageUrl,
  });

  @override
  _PostCreationScreenState createState() => _PostCreationScreenState();
}

class _PostCreationScreenState extends State<PostCreationScreen> {
  RangeValues _currentRangeValues = const RangeValues(10000, 50000);
  final TextEditingController _descriptionController = TextEditingController();
  final Color primaryColor = const Color.fromARGB(255, 213, 247, 41);
  final Color contrastColor = Colors.grey.shade800;

  Future<void> _createPost() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('posts').add({
          'userId': user.uid,
          'make': widget.make,
          'model': widget.model,
          'year': widget.year,
          'imageUrl': widget.imageUrl,
          'minPrice': _currentRangeValues.start,
          'maxPrice': _currentRangeValues.end,
          'description': _descriptionController.text,
          'timestamp': FieldValue.serverTimestamp(),
          'offers': [],
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Post created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create post. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor.withOpacity(0.9),
        title: Text(
          'Create Post',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: contrastColor,
          ),
        ),
        iconTheme: IconThemeData(color: contrastColor),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image:
                AssetImage('assets/pexels-martynas-linge-2836004-19587054.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                  height: MediaQuery.of(context).padding.top + kToolbarHeight),
              _buildContentCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentCard() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCarDetailsSection(),
            SizedBox(height: 20),
            _buildImageSection(),
            SizedBox(height: 20),
            _buildPriceRangeSection(),
            SizedBox(height: 20),
            _buildDescriptionSection(),
            SizedBox(height: 24),
            _buildCreatePostButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCarDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Car Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: contrastColor,
          ),
        ),
        SizedBox(height: 16),
        _buildDetailTile('Make', widget.make.toUpperCase()),
        _buildDetailTile('Model', widget.model.toUpperCase()),
        _buildDetailTile('Year', widget.year),
      ],
    );
  }

  Widget _buildDetailTile(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Car Image',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: contrastColor,
          ),
        ),
        SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: widget.imageUrl.isNotEmpty
              ? Image.network(
                  widget.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: Icon(Icons.image_not_supported, size: 50),
                ),
        ),
      ],
    );
  }

  Widget _buildPriceRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Range',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: contrastColor,
          ),
        ),
        SizedBox(height: 16),
        PriceRangeSlider(
          values: _currentRangeValues,
          onChanged: (RangeValues newValues) {
            setState(() {
              _currentRangeValues = newValues;
            });
          },
        ),
        Center(
          child: Text(
            '\$${_currentRangeValues.start.round()} - \$${_currentRangeValues.end.round()}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: contrastColor,
          ),
        ),
        SizedBox(height: 16),
        TextField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Enter car description...',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildCreatePostButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _createPost,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 213, 247, 41),
          foregroundColor: Colors.grey.shade800,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 24),
            SizedBox(width: 10),
            Text(
              'Create Post',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
