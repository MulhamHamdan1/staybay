import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staybay/cubits/locale/locale_cubit.dart';
import 'package:staybay/cubits/locale/locale_state.dart';
import 'package:staybay/cubits/theme/theme_cubit.dart';
import 'package:staybay/cubits/user/user_cubit.dart';
import 'package:staybay/cubits/user/user_state.dart';
import 'package:staybay/models/user.dart';
import 'package:staybay/screens/bookings_screen.dart';
import 'package:staybay/screens/my_apartments_screen.dart';
import 'package:staybay/screens/welcome_screen.dart';
import 'package:staybay/services/logout_service.dart';

class AccountScreen extends StatelessWidget {
  static const routeName = 'account';

  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        return BlocBuilder<UserCubit, UserState>(
          builder: (context, state) {
            if (state is UserLoading || state is UserInitial) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (state is UserError) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message),
                      _profileTile(
                        context,
                        icon: Icons.refresh,
                        title: "refresh",
                        onTap: () {
                          context.read<UserCubit>().getMe();
                        },
                      ),
                      _profileTile(
                        context,
                        icon: Icons.logout,
                        title: 'تسجيل الخروج',
                        onTap: () async {
                          LogoutService.logout();
                          Navigator.of(
                            context,
                          ).pushNamed(WelcomeScreen.routeName);
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is UserLoaded) {
              final user = state.user;
              return successState(user, theme, localeState, context);
            }
            return const SizedBox();
          },
        );
      },
    );
  }

  Scaffold successState(
    User user,
    ThemeData theme,
    LocaleState localeState,
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor.withAlpha(240),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
        centerTitle: true,
        title: Text(
          'الملف الشخصي',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: TextButton(
              onPressed: () {
                String newLanguage = localeState.currentLanguage == 'EN'
                    ? 'AR'
                    : 'EN';
                context.read<LocaleCubit>().changeLanguage(newLanguage);
              },
              child: Text(
                localeState.currentLanguage,
                style: TextStyle(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            /// ===== PROFILE HEADER =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  /// Profile Image
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 68,
                        backgroundImage: NetworkImage(user.avatar),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () {
                          // تغيير الصورة لاحقًا
                        },
                        child: Container(
                          padding: const EdgeInsets.all(9),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// Name
                  Text(
                    '${user.firstName} ${user.lastName}',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 6),

                  /// Phone
                  Text(
                    user.phone,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            // const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.only(bottom: 15, left: 20, right: 20),
              child: Divider(color: theme.primaryColor, thickness: 2),
            ),

            /// ===== ACTIONS =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _profileTile(
                    context,
                    icon: Icons.favorite_border,
                    title: 'شققي',
                    onTap: () {
                      Navigator.of(
                        context,
                      ).pushNamed(MyApartmentsScreen.routeName);
                    },
                  ),

                  _profileTile(
                    context,
                    icon: Icons.bookmark_border,
                    title: 'حجوزاتي',
                    onTap: () {
                      // Navigator.of(context).pushNamed(BookingsScreen.routeName);
                    },
                  ),

                  _profileTile(
                    context,
                    icon: Icons.dark_mode_outlined,
                    title: 'تبديل الوضع',
                    onTap: () async {
                      context.read<ThemeCubit>().toggleTheme();
                    },
                  ),

                  _profileTile(
                    context,
                    icon: Icons.logout,
                    title: 'تسجيل الخروج',
                    onTap: () async {
                      LogoutService.logout();
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        WelcomeScreen.routeName,
                        (Route<dynamic> route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ===== PROFILE TILE =====
  Widget _profileTile(
    context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor,
              blurRadius: 1,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: ListTile(
          onTap: onTap,
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, size: 26, color: Theme.of(context).primaryColor),
          title: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ),
      ),
    );
  }
}
