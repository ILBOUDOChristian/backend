class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  const NetworkException([String message = 'Impossible de contacter le serveur. Verifiez votre connexion.'])
      : super(message: message);
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException([String message = 'Identifiants invalides ou session expiree.'])
      : super(message: message, statusCode: 401);
}

class ServerException extends ApiException {
  const ServerException([String message = 'Erreur interne du serveur distant.'])
      : super(message: message, statusCode: 500);
}
