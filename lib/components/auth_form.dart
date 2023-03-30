import 'package:flutter/material.dart';

enum AuthMode { login, signUp }

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  AuthMode _authMode = AuthMode.signUp;
  final _passwordController = TextEditingController();

  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  void _submit() {}

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
          height: 320,
          width: deviceSize.width * 0.75,
          padding: const EdgeInsets.all(16),
          child: Form(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    final email = value ?? '';

                    if (email.trim().isEmpty || !email.contains('@')) {
                      return 'Informa um e-mail válido';
                    }

                    return null;
                  },
                  onSaved: (email) => _authData['email'] = email ?? '',
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Senha'),
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    final password = value ?? '';

                    if (password.isEmpty || password.length < 5) {
                      return 'Informa uma senha válida';
                    }
                    return null;
                  },
                  onSaved: (password) => _authData['password'] = password ?? '',
                ),
                if (_authMode == AuthMode.signUp)
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Confirmar senha'),
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    validator: _authMode == AuthMode.login
                        ? null
                        : (_password) {
                            final password = _password ?? '';

                            if (password != _passwordController.text) {
                              return 'Senhas informadas não conferem';
                            }
                            return null;
                          },
                  ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                  ),
                  child: Text(
                      _authMode == AuthMode.login ? 'ENTRAR' : 'REGISTRAR'),
                ),
              ],
            ),
          )),
    );
  }
}
