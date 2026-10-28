import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EcoCard extends StatelessWidget {
  const EcoCard({super.key, required this.child, this.color = AppColors.white,
      this.padding = const EdgeInsets.all(Gaps.m)});
  final Widget child;
  final Color color;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(Gaps.radius),
          boxShadow: const [
            BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: Offset(0, 3)),
          ],
        ),
        child: child,
      );
}

class ErrorRetry extends StatelessWidget {
  const ErrorRetry({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(Gaps.l),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: Gaps.s),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: Gaps.m),
            OutlinedButton(onPressed: onRetry, child: const Text('Reintentar')),
          ]),
        ),
      );
}

class PendingScreen extends StatelessWidget {
  const PendingScreen({super.key, required this.title, required this.icon});
  final String title;
  final IconData icon;
  @override
  Widget build(BuildContext context) => SafeArea(
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 56, color: AppColors.lightGreen),
            const SizedBox(height: Gaps.m),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: Gaps.s),
            const Text('Esta sección se implementa en la próxima etapa.'),
          ]),
        ),
      );
}

/// Construye su contenido recién la primera vez que la pestaña se activa
/// y luego lo conserva (evita cargar teselas del mapa al iniciar la app).
class LazyTab extends StatefulWidget {
  const LazyTab({super.key, required this.active, required this.builder});
  final bool active;
  final Widget Function() builder;
  @override
  State<LazyTab> createState() => _LazyTabState();
}

class _LazyTabState extends State<LazyTab> {
  bool _built = false;
  @override
  Widget build(BuildContext context) {
    if (widget.active) _built = true;
    return _built ? widget.builder() : const SizedBox.shrink();
  }
}
