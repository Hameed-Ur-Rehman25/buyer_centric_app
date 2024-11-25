import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buyer_centric_app/screens/post_creation_screen.dart';
import 'package:buyer_centric_app/screens/all_cars_screen.dart';

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
  }

  Widget _buildAutocompleteField({
    required String label,
    required String hint,
    required List<String> options,
    required TextEditingController controller,
    Function(String)? onSelected,
    String? Function(String?)? validator,
  }) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return options; // Show all options when empty
        }
        return options.where(
          (String option) {
            return option.toLowerCase().contains(
                  textEditingValue.text.toLowerCase(),
                );
          },
        );
      },
      onSelected: (String selection) {
        controller.text = selection;
        if (onSelected != null) {
          onSelected(selection);
        }
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController fieldTextEditingController,
        FocusNode fieldFocusNode,
        VoidCallback onFieldSubmitted,
      ) {
        return TextFormField(
          controller: fieldTextEditingController,
          focusNode: fieldFocusNode,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            suffixIcon: Icon(Icons.arrow_drop_down),
          ),
          validator: validator,
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
            child: Container(
              width: 300,
              constraints: BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final String option = options.elementAt(index);
                  return ListTile(
                    title: Text(option),
                    onTap: () {
                      onSelected(option);
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
              _buildAutocompleteField(
                label: 'Make',
                hint: 'Enter car make',
                options: _carMakes,
                controller: _makeController,
                onSelected: (String selection) {
                  _fetchModels(selection);
                },
              ),
              SizedBox(height: 16),
              _buildAutocompleteField(
                label: 'Model',
                hint: 'Enter car model',
                options: _carModels,
                controller: _modelController,
              ),
              SizedBox(height: 16),
              _buildAutocompleteField(
                label: 'Year',
                hint: 'Enter car year',
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
