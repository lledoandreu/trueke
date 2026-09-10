import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/search/providers/search_filters_provider.dart';

class SearchFiltersWidget extends ConsumerWidget {
  const SearchFiltersWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(searchFiltersProvider);
    final filtersNotifier = ref.read(searchFiltersProvider.notifier);

    final hasLocation = filters.userLat != null && filters.userLng != null;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filtros Avanzados',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => filtersNotifier.clearFilters(),
                child: const Text('Limpiar todo'),
              ),
            ],
          ),
          const Divider(),
          const Text(
            'Ordenar por',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          DropdownButton<String>(
            value: filters.sortBy,
            isExpanded: true,
            items: [
              const DropdownMenuItem(
                value: 'recent',
                child: Text('Más recientes'),
              ),
              const DropdownMenuItem(
                value: 'price_asc',
                child: Text('Precio: de menor a mayor'),
              ),
              const DropdownMenuItem(
                value: 'price_desc',
                child: Text('Precio: de mayor a menor'),
              ),
              if (hasLocation)
                const DropdownMenuItem(
                  value: 'distance',
                  child: Text('Cercanía geográfica'),
                ),
            ],
            onChanged: (value) => filtersNotifier.updateSortBy(value),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Usar mi ubicación actual',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Switch(
                value: hasLocation,
                onChanged: (value) {
                  if (value) {
                    // Coordenadas simuladas de Madrid Centro para testing de proximidad
                    filtersNotifier.updateLocation(40.416775, -3.703790);
                  } else {
                    filtersNotifier.updateLocation(null, null);
                    if (filters.sortBy == 'distance') {
                      filtersNotifier.updateSortBy('recent');
                    }
                  }
                },
              ),
            ],
          ),
          if (hasLocation) ...[
            const SizedBox(height: 16),
            Text(
              'Distancia Máxima: ${filters.maxDistanceKm.round()} km',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Slider(
              value: filters.maxDistanceKm,
              min: 1.0,
              max: 100.0,
              divisions: 99,
              label: '${filters.maxDistanceKm.round()} km',
              onChanged: (value) {
                filtersNotifier.updateMaxDistance(value);
              },
            ),
          ],
          const SizedBox(height: 16),
          const Text(
            'Estado del Producto',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Wrap(
            spacing: 8.0,
            children: ['nuevo', 'como_nuevo', 'bueno', 'aceptable'].map((cond) {
              final isSelected = filters.condition == cond;
              return ChoiceChip(
                label: Text(cond.replaceAll('_', ' ')),
                selected: isSelected,
                onSelected: (selected) {
                  filtersNotifier.updateCondition(selected ? cond : null);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'Rango de Equivalencia Estimada',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          RangeSlider(
            values: RangeValues(
              filters.minPrice ?? 0.0,
              filters.maxPrice ?? 1000.0,
            ),
            min: 0.0,
            max: 1000.0,
            divisions: 20,
            labels: RangeLabels(
              '${(filters.minPrice ?? 0.0).round()}€',
              '${(filters.maxPrice ?? 1000.0).round()}€',
            ),
            onChanged: (values) {
              filtersNotifier.updatePriceRange(values.start, values.end);
            },
          ),
        ],
      ),
    );
  }
}
