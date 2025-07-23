import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:structured/screens/login_page.dart';
import 'package:structured/services/task_controller.dart';
import 'theme/app_theme.dart';
import 'screens/timeline_page.dart';

void main() {
  Get.put(TaskController());
  runApp(GetMaterialApp(
    title: 'Structured Daily Planner',
    theme: AppTheme.lightTheme, // Updated to include light theme
    darkTheme: AppTheme.darkTheme,
    themeMode: ThemeMode.system,
    home: LoginPage(),
    debugShowCheckedModeBanner: false,
    initialBinding: BindingsBuilder(() {
      Get.put(TaskController());
    }),
  ));
}

class AppTheme {
  // Define the primary color (vibrant teal)
  static const Color primaryColor = Color(0xFF26A69A); // Teal
  static const Color accentColor = Color(0xFFFFCA28); // Amber
  static const Color backgroundLight = Color(0xFFF5F5F5); // Light gray
  static const Color backgroundDark = Color(0xFF121212); // Dark gray
  static const Color textPrimaryLight =
      Color(0xFF212121); // Dark text for light theme
  static const Color textPrimaryDark =
      Color(0xFFE0E0E0); // Light text for dark theme
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF1E1E1E);

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      surface: backgroundLight,
      onPrimary: Colors.white, // Text/icons on primary color
      onSecondary: Colors.black, // Text/icons on accent color
      onSurface: textPrimaryLight, // Text on background
    ),
    scaffoldBackgroundColor: backgroundLight,
    cardColor: cardLight,
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimaryLight,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: textPrimaryLight,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: textPrimaryLight,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white, // Text/icons on app bar
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor, // Button background
        foregroundColor: Colors.black, // Button text/icon color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentColor,
      foregroundColor: Colors.black,
    ),
    dividerColor: Colors.grey[300],
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      surface: backgroundDark,
      onPrimary: Colors.white, // Text/icons on primary color
      onSecondary: Colors.black, // Text/icons on accent color
      onSurface: textPrimaryDark, // Text on background
    ),
    scaffoldBackgroundColor: backgroundDark,
    cardColor: cardDark,
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimaryDark,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: textPrimaryDark,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: textPrimaryDark,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentColor,
      foregroundColor: Colors.black,
    ),
    dividerColor: Colors.grey[800],
  );
}




// import 'package:flutter/material.dart';

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false, // Debug-Banner ausblenden
//       home: Scaffold(
//         backgroundColor: Colors
//             .black, // Hintergrundfarbe des Scaffolds, um den Kontrast zu zeigen
//         body: Center(
//           // Zentriert das gesamte UI-Element auf dem Bildschirm
//           child: Padding(
//             padding:
//                 const EdgeInsets.all(16.0), // Abstand vom Rand des Bildschirms
//             child: Container(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//               decoration: BoxDecoration(
//                 color: const Color(
//                     0xFF282828), // Dunkelgraue Hintergrundfarbe des Widgets
//                 borderRadius: BorderRadius.circular(12.0), // Abgerundete Ecken
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize
//                     .min, // Die Row soll nur so viel Platz wie nötig einnehmen
//                 crossAxisAlignment: CrossAxisAlignment
//                     .center, // Vertikale Ausrichtung der Elemente in der Row
//                 children: [
//                   // 1. Linke "00:00" Anzeige
//                   const Text(
//                     '00:00',
//                     style: TextStyle(
//                       color: Color(0xFFAAAAAA), // Helles Grau
//                       fontSize: 16.0,
//                     ),
//                   ),

//                   const SizedBox(width: 20.0), // Abstand zwischen den Elementen

//                   // 2. Rundes Icon-Widget (mit Mond)
//                   Container(
//                     width: 60.0,
//                     height: 60.0,
//                     decoration: BoxDecoration(
//                       color: const Color(
//                           0xFF383838), // Dunkleres Grau für den Kreis
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.nights_stay, // Mond-Icon
//                       color: Color(0xFF64B5F6), // Hellblau
//                       size: 32.0,
//                     ),
//                   ),

//                   const SizedBox(width: 20.0), // Abstand

//                   // 3. Hauptinformationsbereich (Text-Column)
//                   Expanded(
//                     // Nimmt den verbleibenden horizontalen Platz ein
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment
//                           .start, // Links ausrichten der Texte in der Column
//                       mainAxisSize: MainAxisSize
//                           .min, // Column soll nur so hoch wie nötig sein
//                       children: [
//                         // Obere Zeile: Zeit und Refresh-Icon
//                         Row(
//                           mainAxisSize: MainAxisSize
//                               .min, // Die innere Row soll nur so breit wie nötig sein
//                           children: [
//                             const Text(
//                               '00:00', // Das +1 ist hier nicht direkt als Text darstellbar mit ^, müsste als String "00:00+1" sein
//                               style: TextStyle(
//                                 color: Color(0xFFAAAAAA), // Helles Grau
//                                 fontSize: 16.0,
//                               ),
//                             ),
//                             // Füge das "+1" als Superscript hinzu, falls gewünscht. Dies ist mit reinem Textstyles schwierig.
//                             // Hier simulieren wir es einfach als normalen Text oder lassen es weg, da die genaue Darstellung
//                             // von Superscript komplexer ist. Im Originalbild ist es sehr klein.
//                             // Für eine genaue Darstellung bräuchte man vielleicht ein CustomPainter oder spezifische Text-Packages.
//                             // Wir verwenden hier einen einfachen String.
//                             const Text(
//                               '+1', // "+1" als separater Text, um es kleiner zu machen
//                               style: TextStyle(
//                                 color: Color(0xFFAAAAAA),
//                                 fontSize: 12.0, // Kleiner als der Haupttext
//                                 height: 0.8, // Optisch etwas höher rücken
//                               ),
//                             ),
//                             const SizedBox(width: 5.0), // Kleiner Abstand
//                             const Icon(
//                               Icons.refresh, // Refresh-Icon
//                               color: Color(0xFFAAAAAA), // Helles Grau
//                               size: 16.0,
//                             ),
//                           ],
//                         ),
//                         const SizedBox(
//                             height: 4.0), // Kleiner vertikaler Abstand

//                         // Untere Zeile: "Schlafen gehen"
//                         const Text(
//                           'Schlafen gehen',
//                           style: TextStyle(
//                             color: Colors.white, // Weiß
//                             fontSize: 22.0, // Größer und fetter wirkend
//                             fontWeight: FontWeight.w500, // Leicht fett
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(width: 20.0), // Abstand

//                   // 4. Rechter Kreis (Toggle/Indikator)
//                   Container(
//                     width: 30.0,
//                     height: 30.0,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                         color: const Color(0xFF64B5F6), // Hellblaue Umrandung
//                         width: 2.5, // Dicke der Umrandung
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
