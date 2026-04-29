import 'package:flutter/material.dart';

import '../models/campus_place.dart';
import 'app_panel.dart';

class DestinationDetailCard extends StatelessWidget {
  const DestinationDetailCard({
    super.key,
    required this.place,
    required this.onStartNavigation,
  });

  final CampusPlace place;
  final VoidCallback onStartNavigation;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(place.icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('${place.kind} • ${place.area}'),
                    const SizedBox(height: 8),
                    Text(place.description),
                    const SizedBox(height: 8),
                    Text('Mốc gần nhất: ${place.landmark}'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            key: const ValueKey('start-navigation-button'),
            onPressed: onStartNavigation,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Mở camera chỉ đường'),
          ),
        ],
      ),
    );
  }
}
