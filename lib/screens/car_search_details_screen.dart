import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buyer_centric_app/screens/post_creation_screen.dart';
import 'package:buyer_centric_app/screens/all_cars_screen.dart';

class CarSearchDetailsScreen extends StatefulWidget {
  @override
  _CarSearchDetailsScreenState createState() => _CarSearchDetailsScreenState();
}

class _CarSearchDetailsScreenState extends State<CarSearchDetailsScreen> {
  // Key to identify the form and validate it
  final _formKey = GlobalKey<FormState>();

  // Controllers for the input fields
  final TextEditingController _makeController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  // List of car makes to populate the dropdown
  final List<String> _carMakes = [
    'Toyota',
    'Honda',
    'Ford',
    'Chevrolet',
    'Nissan'
  ];

  // List of car models, initially empty
  List<String> _carModels = [];

  // List of car years from 1990 to the current year
  List<String> _carYears = List.generate(
      DateTime.now().year - 1990 + 2, (index) => (1990 + index).toString());

  // Map of car makes to their respective models
  final Map<String, List<String>> _makeToModels = {
    'Toyota': ['Camry', 'Corolla', 'Prius'],
    'Honda': ['Civic', 'Accord', 'Fit'],
    'Ford': ['Focus', 'Mustang', 'Explorer'],
    'Chevrolet': ['Malibu', 'Impala', 'Cruze'],
    'Nissan': ['Altima', 'Sentra', 'Maxima']
  };

  Future<void> _fetchModels(String make) async {
    setState(() {
      _carModels = _makeToModels[make] ?? [];
      _modelController.text = ''; // Clear model when make changes
    });
  }

  Future<void> _searchCar(BuildContext context) async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      // Show error message if validation fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all required fields correctly'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    _formKey.currentState?.save();

    try {
      String make = _makeController.text.trim();
      String model = _modelController.text.trim();
      String year = _yearController.text.trim();

      print('Searching for: Make=$make, Model=$model, Year=$year');

      var carsRef = FirebaseFirestore.instance.collection('cars');

      // Try to find the car
      QuerySnapshot querySnapshot = await carsRef
          .where('make', isEqualTo: make.toLowerCase())
          .where('model', isEqualTo: model.toLowerCase())
          .where('year', isEqualTo: int.parse(year))
          .get();

      if (querySnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Car not found in the database'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      var carData = querySnapshot.docs.first.data() as Map<String, dynamic>;
      print('Car found: $carData');

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
        SnackBar(
          content: Text('Error searching for car: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildAutocompleteField({
    required String label,
    required String hint,
    required List<String> options,
    required TextEditingController controller,
    Function(String)? onSelected,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: contrastColor,
            )),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return options;
              }
              return options.where((String option) => option
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase()));
            },
            onSelected: (String selection) {
              controller.text = selection;
              if (onSelected != null) {
                onSelected(selection);
              }
            },
            fieldViewBuilder: (context, fieldTextEditingController,
                fieldFocusNode, onFieldSubmitted) {
              return TextFormField(
                controller: fieldTextEditingController,
                focusNode: fieldFocusNode,
                style: TextStyle(color: contrastColor),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: accentColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: accentColor.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.red, width: 1),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.red, width: 2),
                  ),
                  errorStyle: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                  suffixIcon: Icon(Icons.arrow_drop_down, color: contrastColor),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                validator: (value) {
                  if (validator != null) {
                    return validator(value);
                  }
                  if (value == null || value.isEmpty) {
                    return 'Please enter a $label';
                  }
                  return null;
                },
              );
            },
            optionsViewBuilder: (
              BuildContext context,
              AutocompleteOnSelected<String> onSelected,
              Iterable<String> options,
            ) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: 300,
                    constraints: BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: accentColor.withOpacity(0.5)),
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final String option = options.elementAt(index);
                        return ListTile(
                          title: Text(option,
                              style: TextStyle(color: contrastColor)),
                          onTap: () => onSelected(option),
                          hoverColor: primaryColor.withOpacity(0.1),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Add these color constants
  final Color primaryColor = const Color.fromARGB(255, 213, 247, 41);
  final Color contrastColor =
      const Color.fromARGB(255, 41, 45, 6); // Dark contrast
  final Color accentColor =
      const Color.fromARGB(255, 156, 179, 36); // Muted lime

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor.withOpacity(0.9),
        title: Text(
          'Find Your Perfect Car',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: contrastColor,
          ),
        ),
        iconTheme: IconThemeData(color: contrastColor),
        actions: [
          IconButton(
            icon: Icon(Icons.list_alt_rounded, color: contrastColor),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AllCarsScreen()));
            },
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image:
                AssetImage('assets/pexels-martynas-linge-2836004-19587054.jpg'),
            fit: BoxFit.fill,
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
              Container(
                padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                margin: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Enter your car details below',
                  style: TextStyle(
                    color: contrastColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildAutocompleteField(
                          label: 'Make',
                          hint: 'Select car manufacturer',
                          options: _carMakes,
                          controller: _makeController,
                          onSelected: (String selection) {
                            _fetchModels(selection);
                          },
                        ),
                        SizedBox(height: 20),
                        _buildAutocompleteField(
                          label: 'Model',
                          hint: 'Select car model',
                          options: _carModels,
                          controller: _modelController,
                        ),
                        SizedBox(height: 20),
                        _buildAutocompleteField(
                          label: 'Year',
                          hint: 'Select manufacturing year',
                          options: _carYears,
                          controller: _yearController,
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
                        ),
                        SizedBox(height: 30),
                        _buildSearchButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Update the search button
  Widget _buildSearchButton() {
    return Container(
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
        onPressed: () => _searchCar(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: contrastColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 24),
            SizedBox(width: 10),
            Text(
              'Search Car',
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
