import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/services/providers.dart';
import '../features/map/presentation/screens/map_screen.dart';
import '../features/preload/presentation/screens/preload_screen.dart';

class PrevozApp extends ConsumerWidget {
  const PrevozApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preloadStatusAsync = ref.watch(isPreloadCompleteProvider);

    return MaterialApp(
      title: 'Prevoz - Podgorica Transit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      home: preloadStatusAsync.when(
        data: (isComplete) {
          // If preload is complete, go to map screen
          // Otherwise, show preload screen
          return isComplete ? const MapScreen() : const PreloadScreen();
        },
        loading: () => const _SplashScreen(),
        error: (error, stackTrace) {
          // On error checking status, show preload screen
          // (it will handle retries)
          return const PreloadScreen();
        },
      ),
    );
  }
}

/// Simple splash screen shown while checking preload status
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_bus,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            const Text(
              'Prevoz',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
