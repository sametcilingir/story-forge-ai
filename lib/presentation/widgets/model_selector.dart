import 'package:flutter/material.dart';

import '../../domain/entities/ai_model.dart';

/// AI Model Selector Widget
/// Presentation Layer - Uses domain entities
class ModelSelector extends StatelessWidget {
  final List<AIModel> models;
  final String selectedModel;
  final bool isLoading;
  final Function(String) onModelSelected;

  const ModelSelector({
    super.key,
    required this.models,
    required this.selectedModel,
    required this.isLoading,
    required this.onModelSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text('Loading models...'),
          ],
        ),
      );
    }

    if (models.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber, size: 18, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'No models available',
                style: TextStyle(color: Colors.orange.shade700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: models.any((m) => m.id == selectedModel)
              ? selectedModel
              : models.first.id,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: models.map((model) {
            return DropdownMenuItem<String>(
              value: model.id,
              child: Row(
                children: [
                  _getProviderIcon(model.provider),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          model.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          model.provider,
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              onModelSelected(value);
            }
          },
        ),
      ),
    );
  }

  Widget _getProviderIcon(String provider) {
    Color color;
    IconData icon;

    switch (provider.toLowerCase()) {
      case 'openai':
        color = Colors.green;
        icon = Icons.psychology;
        break;
      case 'google':
        color = Colors.blue;
        icon = Icons.auto_awesome;
        break;
      case 'anthropic':
        color = Colors.orange;
        icon = Icons.smart_toy;
        break;
      default:
        color = Colors.grey;
        icon = Icons.memory;
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }
}
