import 'package:buyer_centric_app/screens/post_creation_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllCarsScreen extends StatelessWidget {
  Future<List<Map<String, dynamic>>> _fetchAllCars() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('cars')
          .orderBy('make')
          .get();

      print('Fetched ${querySnapshot.docs.length} cars'); // Debug print

      return querySnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        print('Car data: $data'); // Debug print
        return {
          ...data,
          'id': doc.id,
        };
      }).toList();
    } catch (e) {
      print('Error fetching cars: $e'); // Debug print
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Cars'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchAllCars(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No cars found in the database'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var car = snapshot.data![index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: car['imageUrl'] != null
                      ? Container(
                          width: 60,
                          height: 60,
                          child: Image.network(
                            car['imageUrl'],
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(Icons.directions_car, size: 40),
                  title: Text(
                    '${car['make']} ${car['model']}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Year: ${car['year']}'),
                  onTap: () {
                    // Navigate to car details or post creation
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostCreationScreen(
                          make: car['make'],
                          model: car['model'],
                          year: car['year'].toString(),
                          imageUrl: car['imageUrl'] ?? '',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
