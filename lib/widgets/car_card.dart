import 'package:flutter/material.dart';

class CarCard extends StatelessWidget {
  final String make;
  final String model;
  final String year;
  final String imageUrl;
  final VoidCallback onTap;

  const CarCard({
    required this.make,
    required this.model,
    required this.year,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl.isNotEmpty)
              Container(
                height: 150,
                width: double.infinity,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$make $model',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    'Year: $year',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
