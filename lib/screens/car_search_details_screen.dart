import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buyer_centric_app/screens/post_creation_screen.dart';
import 'package:buyer_centric_app/screens/all_cars_screen.dart';
import 'package:buyer_centric_app/widgets/custom_input_field.dart';

class CarSearchDetailsScreen extends StatefulWidget {
  @override
  _CarSearchDetailsScreenState createState() => _CarSearchDetailsScreenState();
}

class _CarSearchDetailsScreenState extends State<CarSearchDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _makeController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  final List<String> _carMakes = [
    'Toyota',
    'Honda',
    'Ford',
    'Chevrolet',
    'Nissan'
  ];
  List<String> _carModels = [];
  List<String> _carYears = List.generate(
      DateTime.now().year - 1990 + 2, (index) => (1990 + index).toString());

  final Map<String, List<String>> _makeToModels = {
    'Toyota': ['Camry', 'Corolla', 'Prius'],
    'Honda': ['Civic', 'Accord', 'Fit'],
    'Ford': ['Mustang', 'F-150', 'Explorer'],
    'Chevrolet': ['Impala', 'Malibu', 'Tahoe'],
    'Nissan': ['Altima', 'Sentra', 'Maxima'],
  };

  Future<void> _fetchModels(String make) async {
    setState(() {
      _carModels = _makeToModels[make] ?? [];
      _modelController.text = ''; // Clear model when make changes
    });
  }

  Future<void> _searchCar(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      try {
        String make = _makeController.text.trim();
        String model = _modelController.text.trim();
        String year = _yearController.text.trim();

        print('Searching for: Make=$make, Model=$model, Year=$year');

        var carsRef = FirebaseFirestore.instance.collection('cars');

        // Create test car data
        var testCar = {
          'make': make.toLowerCase(),
          'model': model.toLowerCase(),
          'year': int.parse(year),
          'imageUrl':
              "https://platform.cstatic-images.com/large/in/v2/stock_photos/efc2df08-a513-4caa-ab68-6310da6e72ff/d9e3b2c0-552e-4764-ba72-ba207220d907.png"
        };

        // Try to find the car
        QuerySnapshot querySnapshot = await carsRef
            .where('make', isEqualTo: make.toLowerCase())
            .where('model', isEqualTo: model.toLowerCase())
            .where('year', isEqualTo: int.parse(year))
            .get();

        if (querySnapshot.docs.isEmpty) {
          // If car doesn't exist, add it
          await carsRef.add(testCar);
          print('Added new car to database'); // Debug print

          // Get the newly added car
          querySnapshot = await carsRef
              .where('make', isEqualTo: make.toLowerCase())
              .where('model', isEqualTo: model.toLowerCase())
              .where('year', isEqualTo: int.parse(year))
              .get();
        }

        var carData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        print('Car found/created: $carData');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostCreationScreen(
              make: make,
              model: model,
              year: year,
              imageUrl: carData['imageUrl'] ?? '',
            ),
          ),
        );
      } catch (e) {
        print('Error searching for car: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching for car: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Car'),
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AllCarsScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  return _carMakes.where((String option) {
                    return option
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase());
                  });
                },
                onSelected: (String selection) {
                  _makeController.text = selection;
                  _fetchModels(selection);
                },
                fieldViewBuilder: (BuildContext context,
                    TextEditingController fieldTextEditingController,
                    FocusNode fieldFocusNode,
                    VoidCallback onFieldSubmitted) {
                  return CustomInputField(
                    label: 'Make',
                    hint: 'Enter car make',
                    controller: fieldTextEditingController,
                    onSaved: (value) {
                      _makeController.text = value ?? '';
                    },
                  );
                },
              ),
              SizedBox(height: 10),
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  return _carModels.where((String option) {
                    return option
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase());
                  });
                },
                onSelected: (String selection) {
                  _modelController.text = selection;
                },
                fieldViewBuilder: (BuildContext context,
                    TextEditingController fieldTextEditingController,
                    FocusNode fieldFocusNode,
                    VoidCallback onFieldSubmitted) {
                  return CustomInputField(
                    label: 'Model',
                    hint: 'Enter car model',
                    controller: fieldTextEditingController,
                    onSaved: (value) {
                      _modelController.text = value ?? '';
                    },
                  );
                },
              ),
              SizedBox(height: 10),
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  return _carYears.where((String option) {
                    return option.contains(textEditingValue.text);
                  });
                },
                onSelected: (String selection) {
                  _yearController.text = selection;
                },
                fieldViewBuilder: (BuildContext context,
                    TextEditingController fieldTextEditingController,
                    FocusNode fieldFocusNode,
                    VoidCallback onFieldSubmitted) {
                  return CustomInputField(
                    label: 'Year',
                    hint: 'Enter car year (e.g., 2022)',
                    keyboardType: TextInputType.number,
                    controller: fieldTextEditingController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a year';
                      }
                      int? year = int.tryParse(value);
                      if (year == null) {
                        return 'Please enter a valid year';
                      }
                      if (year < 1990 || year > DateTime.now().year + 1) {
                        return 'Please enter a year between 1990 and ${DateTime.now().year + 1}';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _yearController.text = value ?? '';
                    },
                  );
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _searchCar(context),
                child: Text('Search Car'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
