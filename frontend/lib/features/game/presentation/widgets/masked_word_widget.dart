import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

class MaskedWordWidget extends StatelessWidget {
  const MaskedWordWidget({super.key, required this.maskedWord});

  final String maskedWord;

  static const double _maxTokenSize = 52;
  static const double _minVisualTokenSize = 14;
  static const double _maxGap = 8;
  static const double _minGap = 1;

  @override
  Widget build(BuildContext context) {
    final tokens = maskedWord.split(' ').where((t) => t.isNotEmpty).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (tokens.isEmpty) {
            return const SizedBox.shrink();
          }

          final count = tokens.length;

          double gap = _maxGap;
          double tokenSize =
              (constraints.maxWidth - ((count - 1) * gap)) / count;

          if (tokenSize > _maxTokenSize) {
            tokenSize = _maxTokenSize;
          }

          if (tokenSize < 18) {
            gap = 4;
            tokenSize = (constraints.maxWidth - ((count - 1) * gap)) / count;
          }

          if (tokenSize < 16) {
            gap = 2;
            tokenSize = (constraints.maxWidth - ((count - 1) * gap)) / count;
          }

          if (tokenSize < _minVisualTokenSize) {
            gap = _minGap;
            tokenSize = (constraints.maxWidth - ((count - 1) * gap)) / count;
          }

          tokenSize = tokenSize.clamp(_minVisualTokenSize, _maxTokenSize);

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < tokens.length; i++) ...[
                Expanded(
                  child: Center(
                    child: _WordToken(token: tokens[i], size: tokenSize),
                  ),
                ),
                if (i != tokens.length - 1) SizedBox(width: gap),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _WordToken extends StatelessWidget {
  const _WordToken({required this.token, required this.size});

  final String token;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isRevealed = token != '_';
    final borderWidth = size < 20 ? 1.0 : 1.5;
    final textSize = size * 0.42;
    final dotSize = (size * 0.18).clamp(2.0, 10.0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isRevealed
            ? AppColors.surfaceContainerHigh
            : AppColors.surfaceContainerHigh.withValues(alpha: 0.12),
        border: Border.all(
          color: isRevealed
              ? AppColors.primary
              : AppColors.outlineVariant.withValues(alpha: 0.35),
          width: borderWidth,
        ),
        boxShadow: isRevealed && size > 22
            ? [
                BoxShadow(
                  color: AppColors.primaryGlow.withValues(alpha: 0.6),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : const [],
      ),
      alignment: Alignment.center,
      child: isRevealed
          ? FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                token.toUpperCase(),
                style: AppTextStyles.title.copyWith(
                  color: AppColors.primary,
                  fontSize: textSize,
                ),
              ),
            )
          : Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.outlineVariant.withValues(alpha: 0.75),
              ),
            ),
    );
  }
}
