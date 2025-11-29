// import 'package:sta';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staybay/cubits/locale/locale_state.dart';
import 'package:staybay/cubits/locale/locale_cubit.dart';
import 'package:staybay/test.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
  // runApp(
  //   BlocProvider(
  //     create: (_) => LocaleCubit(),
  //     child: BlocBuilder<LocaleCubit, LocaleState>(
  //       builder: (context, state) {
  //         return Directionality(
  //           textDirection: state.textDirection,
  //           child: const MyApp(),
  //         );
  //       },
  //     ),
  //   ),
  // );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LocaleCubit(),
      child: MaterialApp(
        builder: (context, child) {
          return BlocBuilder<LocaleCubit, LocaleState>(
            builder: (context, state) {
              return Directionality(
                textDirection: state.textDirection,
                child: child!,
              );
            },
          );
        },
        home: Test(),
      ),
    );
  }
}
