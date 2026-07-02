import 'package:flutter/material.dart';
import 'package:k_passwort/ui/theme/color_scheme.dart';

class GradientScaffold extends StatelessWidget {
  const GradientScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset = true,
    this.showGradient = true,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool resizeToAvoidBottomInset;
  final bool showGradient;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final gradientCenter = Color.lerp(
      primary,
      KPasswortColors.isLight ? Colors.white : Colors.black,
      0.88,
    )!;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: showGradient
          ? Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.7, -0.8),
                  radius: 1.2,
                  colors: [gradientCenter, KPasswortColors.background],
                ),
              ),
              child: body,
            )
          : body,
    );
  }
}
