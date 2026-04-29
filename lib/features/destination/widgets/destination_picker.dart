import 'package:flutter/material.dart';

import '../models/campus_place.dart';
import 'app_panel.dart';

class DestinationPicker extends StatelessWidget {
  const DestinationPicker({
    super.key,
    required this.controller,
    required this.suggestions,
    required this.selectedPlace,
    required this.onQueryChanged,
    required this.onPlaceSelected,
  });

  final TextEditingController controller;
  final List<CampusPlace> suggestions;
  final CampusPlace selectedPlace;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<CampusPlace> onPlaceSelected;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Tìm phòng học / địa điểm',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('destination-field'),
            controller: controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'VD: Khu E, Khu A2, Thư viện khu A',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: onQueryChanged,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final place in suggestions)
                ChoiceChip(
                  selected: place.id == selectedPlace.id,
                  avatar: Icon(place.icon, size: 18),
                  label: Text(place.name),
                  onSelected: (_) => onPlaceSelected(place),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
