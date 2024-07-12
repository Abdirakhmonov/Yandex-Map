import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../bloc/map_cubit.dart';
import '../model/restaurant.dart';

class AddNewRestaurant extends StatefulWidget {
  final Point location;

  const AddNewRestaurant({super.key, required this.location});

  @override
  State<AddNewRestaurant> createState() => _AddNewRestaurantState();
}

class _AddNewRestaurantState extends State<AddNewRestaurant> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();

  void _addRestaurant() {
    final String title = _titleController.text;
    final String phoneNumber = _phoneNumberController.text;
    final double? rating = double.tryParse(_ratingController.text);

    if (title.isNotEmpty && phoneNumber.isNotEmpty && rating != null) {
      final Restaurant restaurant = Restaurant(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
        number: phoneNumber,
        rating: rating,
        location: widget.location,
        imageUrl:
            'https://media.timeout.com/images/106043389/750/562/image.jpg',
      );

      context.read<MapCubit>().addRestaurant(restaurant: restaurant);

      Navigator.pop(context, restaurant);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fill all fields'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add new restaurant'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
            ),
          ),
          TextField(
            controller: _phoneNumberController,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
            ),
            keyboardType: TextInputType.phone,
          ),
          TextField(
            controller: _ratingController,
            decoration: const InputDecoration(
              labelText: 'Rating',
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addRestaurant,
          child: const Text('Add'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _phoneNumberController.dispose();
    _ratingController.dispose();
    super.dispose();
  }
}
