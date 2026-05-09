import 'package:evento_app/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthAware extends StatelessWidget {
  final Widget child;
  final String? routeName;
  final Object? routeArguments;

  const AuthAware({
    super.key,
    required this.child,
    this.routeName,
    this.routeArguments,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final hasToken = (auth.token ?? '').isNotEmpty;
        if (hasToken) return child;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          final modal = ModalRoute.of(context);
          final currentName = routeName ?? modal?.settings.name;
          final currentArgs = routeArguments ?? modal?.settings.arguments;
          if (auth.pendingRedirect?.name != currentName) {
            auth.setPendingRedirect(
              RouteSettings(name: currentName, arguments: currentArgs),
            );
          }
          if (!auth.navigatingToLogin) {
            auth.onAuthExpired(
              from: RouteSettings(name: currentName, arguments: currentArgs),
            );
          }
        });
        return const SizedBox.shrink();
      },
    );
  }
}
