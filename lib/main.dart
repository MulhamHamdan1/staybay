import 'dart:convert';
// import 'package:sta';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staybay/my_color.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // final String responseEN = await rootBundle.loadString(
  //   'assets/locales/EN.json',
  // );
  // final Map<String, dynamic> en = jsonDecode(responseEN);
  // final String responseAR = await rootBundle.loadString(
  //   'assets/locales/AR.json',
  // );
  // final Map<String, dynamic> ar = jsonDecode(responseAR);
  // final Map<String, dynamic> local = en;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        //BlocProvider(create: (context) => LocaleCubit()),
        // BlocProvider(create: (context) => SubjectBloc()),
      ],
      child: MaterialApp(
        theme: ThemeData.light().copyWith(
          extensions: <ThemeExtension<dynamic>>[
            const MyColors(brandColor: Colors.blue, danger: Colors.red),
          ],
        ),
        darkTheme: ThemeData.dark().copyWith(
          extensions: <ThemeExtension<dynamic>>[
            const MyColors(
              brandColor: Colors.lightBlue,
              danger: Colors.redAccent,
            ),
          ],
        ),
      ),
    );
  }
}
