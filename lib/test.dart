import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staybay/cubits/locale/locale_cubit.dart';
import 'package:staybay/cubits/locale/locale_state.dart';

class Test extends StatelessWidget {
  const Test({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, state) {
        return Scaffold(
          body: Center(
            child: Row(
              children: [
                Text(state.localizedStrings['hello'] ?? ''),
                Text(state.localizedStrings['des'] ?? ''),
                ElevatedButton(
                  onPressed: () {
                    String newLanguage = state.currentLanguage == 'EN'
                        ? 'AR'
                        : 'EN';
                    context.read<LocaleCubit>().changeLanguage(newLanguage);
                  },
                  child: Text(state.localizedStrings['change language'] ?? ''),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
