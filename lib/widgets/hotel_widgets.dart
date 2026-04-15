import 'package:flutter/material.dart';

class SoftPanel extends StatelessWidget {
  const SoftPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.backgroundColor,
    this.borderColor,
    this.radius = 22,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color:
              borderColor ?? theme.colorScheme.primary.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final shouldStack = trailing != null && constraints.maxWidth < 720;
        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eyebrow.toUpperCase(),
              style: textTheme.labelLarge?.copyWith(
                letterSpacing: 1.1,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(title, style: textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text(subtitle, style: textTheme.bodyLarge),
          ],
        );

        if (shouldStack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              content,
              if (trailing != null) ...[
                const SizedBox(height: 16),
                trailing!,
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: content),
            if (trailing != null) ...[
              const SizedBox(width: 16),
              trailing!,
            ],
          ],
        );
      },
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.value,
    required this.label,
    required this.detail,
    required this.icon,
  });

  final String value;
  final String label;
  final String detail;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SoftPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.secondary),
          const SizedBox(height: 20),
          Text(value, style: theme.textTheme.displayMedium),
          const SizedBox(height: 4),
          Text(label, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(detail, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class FeaturePill extends StatelessWidget {
  const FeaturePill({
    super.key,
    required this.label,
    this.icon,
  });

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: theme.colorScheme.secondary),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PhotoHero extends StatelessWidget {
  const PhotoHero({
    super.key,
    required this.imagePath,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    this.height = 260,
    this.action,
  });

  final String imagePath;
  final String eyebrow;
  final String title;
  final String subtitle;
  final double height;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 880;
        final imageHeight = height < 220 ? 168.0 : 184.0;

        final label = Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withValues(
                  alpha: 0.12,
                ),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            eyebrow.toUpperCase(),
            style: textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
              letterSpacing: 1.0,
            ),
          ),
        );

        final content = Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment:
                wide ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              label,
              const SizedBox(height: 14),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Text(
                  title,
                  style: (wide
                          ? textTheme.displayMedium
                          : textTheme.headlineMedium)
                      ?.copyWith(height: 1.05),
                ),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Text(subtitle, style: textTheme.bodyLarge),
              ),
              if (action != null) ...[
                const SizedBox(height: 18),
                action!,
              ],
            ],
          ),
        );

        final image = ClipRRect(
          borderRadius: wide
              ? const BorderRadius.only(
                  topRight: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                )
              : const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
          child: SizedBox(
            height: wide ? double.infinity : imageHeight,
            width: double.infinity,
            child: Image.asset(imagePath, fit: BoxFit.cover),
          ),
        );

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.03),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: wide
              ? SizedBox(
                  height: height,
                  child: Row(
                    children: [
                      Expanded(flex: 11, child: content),
                      Expanded(flex: 9, child: image),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    image,
                    content,
                  ],
                ),
        );
      },
    );
  }
}
