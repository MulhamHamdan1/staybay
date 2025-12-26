import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staybay/cubits/locale/locale_cubit.dart';
import 'package:staybay/cubits/locale/locale_state.dart';
import 'package:staybay/cubits/theme/theme_cubit.dart';
import 'package:staybay/cubits/theme/theme_state.dart';
import 'package:staybay/models/user.dart';
import 'package:staybay/services/get_me_service.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  late final User user;
  @override
  void initState() {
    user = GetMeService.getMe() as User;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themestate) {
        return BlocBuilder<LocaleCubit, LocaleState>(
          builder: (context, localestate) {
            return Scaffold(
              body: Row(
                children: [
                  Text(user.avatar),
                  Text(user.firstName),
                  Text(user.lastName),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
