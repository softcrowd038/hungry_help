import 'package:flutter/material.dart';

class LoadingImageWidget extends StatelessWidget {
  const LoadingImageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.secondaryContainer,
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.orange,
        ),
      ),
    );
  }
}
