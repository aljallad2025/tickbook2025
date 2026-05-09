class AuthRequiredException implements Exception {
  final String message;
  const AuthRequiredException([this.message = 'Authentication required']);

  @override
  String toString() => message;
}

