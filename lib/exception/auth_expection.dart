class AuthException implements Exception {
  static const Map<String, String> errors = {
    'EMAIL_EXISTS': 'O e-mail já existe.',
    'OPERATION_NOT_ALLOWED': 'Operação não permitida.',
    'TOO_MANY_ATTEMPTS_TRY_LATER':
        'Acesso bloqueado temporariamente. Tente novamente mais tarde.',
    'EMAIL_NOT_FOUND': 'O e-mail não foi encontrado.',
    'INVALID_PASSWORD': 'Senha inválida!',
    'USER_DISABLED': 'A conta do usuário foi desabilitada.',
  };
  final String key;

  AuthException(this.key);

  @override
  String toString() {
    // TODO: implement toString
    return errors[key] ?? 'Ocorreu um erro de autenticação.';
  }
}
