import 'package:flutter/material.dart';

/// Grid of tappable tiles. Each tap cycles the tile to its next value —
/// the engine judges whether exactly one tile changed and the pattern holds.
class TileBoard extends StatelessWidget {
  final Map<String, dynamic> state;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const TileBoard({super.key, required this.state, required this.onChanged});

  static const _tileColors = [
    Color(0xFF3B5BFF),
    Color(0xFFF5A623),
    Color(0xFF22B573),
    Color(0xFF7A5CFF),
  ];
  static const _tileIcons = [
    Icons.circle,
    Icons.square,
    Icons.change_history,
    Icons.star,
  ];

  @override
  Widget build(BuildContext context) {
    final size = widget.state['size'] as int;
    final options = widget.state['options'] as int;
    final grid = List<int>.from(widget.state['grid'] as List);
    final scheme = Theme.of(context).colorScheme;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: size,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: grid.length,
      itemBuilder: (context, i) {
        final v = grid[i] % _tileColors.length;
        return GestureDetector(
          onTap: () {
            final nextGrid = List<int>.from(grid);
            nextGrid[i] = (nextGrid[i] + 1) % options;
            final next = Map<String, dynamic>.from(widget.state);
            next['grid'] = nextGrid;
            onChanged(next);
          },
          child: Container(
            decoration: BoxDecoration(
              color: _tileColors[v].withOpacity(0.16),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _tileColors[v].withOpacity(0.55),
                width: 1.5,
              ),
            ),
            child: Icon(
              _tileIcons[v % _tileIcons.length],
              color: scheme.brightness == Brightness.dark
                  ? _tileColors[v].withOpacity(0.95)
                  : _tileColors[v],
              size: 30,
            ),
          ),
        );
      },
    );
  }
}
