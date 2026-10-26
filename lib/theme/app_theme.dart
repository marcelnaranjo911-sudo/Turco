
import 'package:flutter/material.dart';

/// Único archivo donde se declaran colores. Las vistas solo usan el tema.
class AppTheme {
  AppTheme._();

  static const Color _seed = Color(0xFF00695C);

  static final ColorScheme _esquemaClaro = ColorScheme.fromSeed(
    seedColor: _seed,
    brightness: Brightness.light,
  ).copyWith(
    primary: const Color(0xFF006A60),
    onPrimary: const Color(0xFFFFFFFF),
    primaryContainer: const Color(0xFF9EF2E4),
    onPrimaryContainer: const Color(0xFF00201C),
    secondaryContainer: const Color(0xFFCCE8E2),
    onSecondaryContainer: const Color(0xFF051F1B),
    tertiary: const Color(0xFF456179),
    onTertiary: const Color(0xFFFFFFFF),
    tertiaryContainer: const Color(0xFFCDE5FF),
    onTertiaryContainer: const Color(0xFF001D32),
    error: const Color(0xFFBA1A1A),
    onError: const Color(0xFFFFFFFF),
    errorContainer: const Color(0xFFFFDAD6),
    onErrorContainer: const Color(0xFF410002),
    surface: const Color(0xFFF4FBF9),
    onSurface: const Color(0xFF161D1C),
    onSurfaceVariant: const Color(0xFF3F4947),
    surfaceContainer: const Color(0xFFE9EFED),
    surfaceContainerHigh: const Color(0xFFE3EAE8),
    surfaceContainerHighest: const Color(0xFFE3EAE8),
    outline: const Color(0xFF6F7977),
    outlineVariant: const Color(0xFFBEC9C6),
  );

  static final ColorScheme _esquemaOscuro = ColorScheme.fromSeed(
    seedColor: _seed,
    brightness: Brightness.dark,
  ).copyWith(
    primary: const Color(0xFF53DBC9),
    onPrimary: const Color(0xFF003731),
    primaryContainer: const Color(0xFF005047),
    onPrimaryContainer: const Color(0xFF9EF2E4),
    secondaryContainer: const Color(0xFF314B47),
    onSecondaryContainer: const Color(0xFFCCE8E2),
    tertiary: const Color(0xFFADCAE6),
    onTertiary: const Color(0xFF153349),
    tertiaryContainer: const Color(0xFF2D4A62),
    onTertiaryContainer: const Color(0xFFCDE5FF),
    error: const Color(0xFFFFB4AB),
    onError: const Color(0xFF690005),
    errorContainer: const Color(0xFF93000A),
    onErrorContainer: const Color(0xFFFFDAD6),
    surface: const Color(0xFF0E1514),
    onSurface: const Color(0xFFDDE4E2),
    onSurfaceVariant: const Color(0xFFBEC9C6),
    surfaceContainer: const Color(0xFF1A2120),
    surfaceContainerHigh: const Color(0xFF252B2A),
    surfaceContainerHighest: const Color(0xFF252B2A),
    outline: const Color(0xFF899390),
    outlineVariant: const Color(0xFF3F4947),
  );

  static ThemeData get claro => _construir(_esquemaClaro);
  static ThemeData get oscuro => _construir(_esquemaOscuro);

  static ThemeData _construir(ColorScheme cs) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      fontFamily: 'Poppins',
      scaffoldBackgroundColor: cs.surface,
    );
    final t = base.textTheme;
    final radio12 = BorderRadius.circular(12);

    OutlineInputBorder borde(Color color, [double ancho = 1]) =>
        OutlineInputBorder(
          borderRadius: radio12,
          borderSide: BorderSide(color: color, width: ancho),
        );

    return base.copyWith(
      textTheme: t.copyWith(
        headlineSmall: t.headlineSmall
            ?.copyWith(fontSize: 24, fontWeight: FontWeight.w600),
        titleLarge:
        t.titleLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.w600),
        titleMedium:
        t.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
        bodyMedium:
        t.bodyMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w400),
        labelSmall:
        t.labelSmall?.copyWith(fontSize: 11, fontWeight: FontWeight.w500),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        scrolledUnderElevation: 0,
        titleTextStyle: t.titleLarge?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: cs.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: cs.surfaceContainer,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: radio12),
          minimumSize: const Size(64, 46),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: radio12),
          minimumSize: const Size(64, 46),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: radio12),
          side: BorderSide(color: cs.outline),
          minimumSize: const Size(64, 46),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: borde(cs.outline),
        enabledBorder: borde(cs.outline),
        focusedBorder: borde(cs.primary, 2),
        errorBorder: borde(cs.error, 2),
        focusedErrorBorder: borde(cs.error, 2),
        disabledBorder: borde(cs.outlineVariant),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cs.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cs.surface,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cs.surfaceContainer,
        indicatorColor: cs.secondaryContainer,
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }
}