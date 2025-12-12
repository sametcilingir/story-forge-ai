import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

/// Genre Selector Widget
class GenreSelector extends StatelessWidget {
  final String selectedGenre;
  final Function(String) onGenreSelected;

  const GenreSelector({
    super.key,
    required this.selectedGenre,
    required this.onGenreSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.getGenreColor(selectedGenre).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getGenreColor(selectedGenre).withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedGenre,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: AppTheme.getGenreColor(selectedGenre),
          ),
          items: AppConstants.genres.map((genre) {
            return DropdownMenuItem<String>(
              value: genre,
              child: Row(
                children: [
                  Icon(
                    _getGenreIcon(genre),
                    size: 18,
                    color: AppTheme.getGenreColor(genre),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppConstants.genreDisplayNames[genre] ?? genre,
                    style: TextStyle(
                      color: AppTheme.getGenreColor(genre),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              onGenreSelected(value);
            }
          },
        ),
      ),
    );
  }

  IconData _getGenreIcon(String genre) {
    switch (genre) {
      case 'fantasy':
        return Icons.auto_fix_high;
      case 'sci-fi':
        return Icons.rocket_launch;
      case 'mystery':
        return Icons.search;
      case 'romance':
        return Icons.favorite;
      case 'horror':
        return Icons.nights_stay;
      case 'adventure':
        return Icons.explore;
      default:
        return Icons.book;
    }
  }
}
