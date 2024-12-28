import 'package:flutter/material.dart';

class PriceRangeSlider extends StatelessWidget {
  final RangeValues values;
  final Function(RangeValues) onChanged;

  const PriceRangeSlider({
    super.key,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const Text(
          //   'Price Range',
          //   style: TextStyle(
          //     fontSize: 18,
          //     fontWeight: FontWeight.bold,
          //     color: Colors.blue,
          //   ),
          // ),
          // const SizedBox(height: 8),
          RangeSlider(
            values: values,
            max: 100000,
            min: 0,
            divisions: 100,
            activeColor: const Color.fromARGB(255, 213, 247, 41),
            inactiveColor: const Color.fromARGB(225, 213, 247, 41),
            labels: RangeLabels(
              '\$${values.start.round()}',
              '\$${values.end.round()}',
            ),
            onChanged: onChanged,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${values.start.round()}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${values.end.round()}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
