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
          SnackBar(content: Text('Post created successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create post. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Post'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Car Details Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Car Details',
                          style: Theme.of(context).textTheme.titleLarge),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.directions_car),
                        title: Text('Make'),
                        subtitle: RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyMedium,
                            children: [
                              TextSpan(
                                text: widget.make.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.model_training),
                        title: Text('Model'),
                        subtitle: RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyMedium,
                            children: [
                              TextSpan(
                                text: widget.model.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.calendar_today),
                        title: Text('Year'),
                        subtitle: RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyMedium,
                            children: [
                              TextSpan(
                                text: widget.year,
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Car Image Card
              Card(
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Car Image',
                          style: Theme.of(context).textTheme.titleLarge),
                    ),
                    if (widget.imageUrl.isNotEmpty)
                      Container(
                        width: double.infinity,
                        height: 200,
                        child: Image.network(
                          widget.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            print('Error loading image: $error');
                            return Container(
                              color: Colors.grey[300],
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error_outline, size: 40),
                                    SizedBox(height: 8),
                                    Text('Error loading image'),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    else
                      Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_not_supported, size: 40),
                              Text('No Image Available'),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Price Range Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Price Range',
                          style: Theme.of(context).textTheme.titleLarge),
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
                          'Selected Range: \$${_currentRangeValues.start.round()} - \$${_currentRangeValues.end.round()}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Description Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Description',
                          style: Theme.of(context).textTheme.titleLarge),
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
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Create Post Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _createPost,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text('Post'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
