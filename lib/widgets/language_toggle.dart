import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../theme.dart';

/// Small pill in the top corner that switches between English and Arabic.
/// It names the language it switches *to*.
class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      top: 0,
      end: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Semantics(
            button: true,
            label: S.changeLanguage(context),
            excludeSemantics: true,
            child: Material(
              color: Colors.white.withValues(alpha: 0.9),
              shape: const StadiumBorder(),
              elevation: 2,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: appLocale.toggle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.translate,
                        size: 16,
                        color: AppColors.foreground,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        S.switchLanguage(context),
                        style: AppText.body(15, height: 1.2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
