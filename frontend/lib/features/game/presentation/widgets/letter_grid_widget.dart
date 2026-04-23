import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

class LetterGridWidget extends StatelessWidget {
  const LetterGridWidget({
    super.key,
    required this.correctLetters,
    required this.wrongLetters,
    required this.guessedLetters,
    required this.disabled,
    required this.onLetterTap,
  });

  final Set<String> correctLetters;
  final Set<String> wrongLetters;
  final Set<String> guessedLetters;
  final bool disabled;
  final ValueChanged<String> onLetterTap;

  static const List<List<String>> _rows = [
    ['a', 'b', 'c', 'd', 'e', 'f', 'g'],
    ['h', 'i', 'j', 'k', 'l', 'm', 'n'],
    ['o', 'p', 'q', 'r', 's', 't', 'u'],
    ['v', 'w', 'x', 'y', 'z'],
  ];

  static const double _horizontalGap = 8;
  static const double _verticalGap = 12;
  static const int _maxColumns = 7;
  static const double _maxKeySize = 44;
  static const double _minKeySize = 34;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalHorizontalSpacing = (_maxColumns - 1) * _horizontalGap;
        final rawKeySize =
            (constraints.maxWidth - totalHorizontalSpacing) / _maxColumns;

        final keySize = rawKeySize.clamp(_minKeySize, _maxKeySize);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final row in _rows) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < row.length; i++) ...[
                    _LetterKey(
                      letter: row[i],
                      size: keySize,
                      disabled: disabled,
                      isCorrect: correctLetters.contains(row[i]),
                      isWrong: wrongLetters.contains(row[i]),
                      isGuessed: guessedLetters.contains(row[i]),
                      onTap: () => onLetterTap(row[i]),
                    ),
                    if (i != row.length - 1)
                      const SizedBox(width: _horizontalGap),
                  ],
                ],
              ),
              if (row != _rows.last) const SizedBox(height: _verticalGap),
            ],
          ],
        );
      },
    );
  }
}

class _LetterKey extends StatelessWidget {
  const _LetterKey({
    required this.letter,
    required this.size,
    required this.disabled,
    required this.isCorrect,
    required this.isWrong,
    required this.isGuessed,
    required this.onTap,
  });

  final String letter;
  final double size;
  final bool disabled;
  final bool isCorrect;
  final bool isWrong;
  final bool isGuessed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isInteractive = !disabled && !isGuessed;

    final _LetterVisualState visual = _resolveVisualState(
      isCorrect: isCorrect,
      isWrong: isWrong,
      disabled: disabled,
      isGuessed: isGuessed,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: visual.backgroundColor,
        border: Border.all(color: visual.borderColor, width: 1.5),
        boxShadow: visual.shadows,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: isInteractive ? onTap : null,
          customBorder: const CircleBorder(),
          child: Center(
            child: Text(
              letter.toUpperCase(),
              style: AppTextStyles.bodyBold.copyWith(
                color: visual.textColor,
                fontSize: size * 0.34,
              ),
            ),
          ),
        ),
      ),
    );
  }

  _LetterVisualState _resolveVisualState({
    required bool isCorrect,
    required bool isWrong,
    required bool disabled,
    required bool isGuessed,
  }) {
    if (isCorrect) {
      return _LetterVisualState(
        borderColor: AppColors.success,
        backgroundColor: AppColors.success.withValues(alpha: 0.15),
        textColor: AppColors.success,
        shadows: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.30),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      );
    }

    if (isWrong) {
      return _LetterVisualState(
        borderColor: AppColors.error.withValues(alpha: 0.75),
        backgroundColor: AppColors.error.withValues(alpha: 0.08),
        textColor: AppColors.error.withValues(alpha: 0.75),
        shadows: const [],
      );
    }

    final borderColor = AppColors.primary.withValues(
      alpha: disabled && !isGuessed ? 0.18 : 0.40,
    );

    final textColor = disabled && !isGuessed
        ? AppColors.primary.withValues(alpha: 0.30)
        : AppColors.primary;

    return _LetterVisualState(
      borderColor: borderColor,
      backgroundColor: Colors.transparent,
      textColor: textColor,
      shadows: const [],
    );
  }
}

class _LetterVisualState {
  const _LetterVisualState({
    required this.borderColor,
    required this.backgroundColor,
    required this.textColor,
    required this.shadows,
  });

  final Color borderColor;
  final Color backgroundColor;
  final Color textColor;
  final List<BoxShadow> shadows;
}
