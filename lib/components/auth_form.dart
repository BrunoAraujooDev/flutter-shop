import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/auth.dart';

enum AuthMode { login, signUp }

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  AuthMode _authMode = AuthMode.signUp;
  final TextEditingController _passwordController = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  bool _isLoading = false;

  final Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  bool isLogin() => _authMode == AuthMode.login;
  bool isSignUp() => _authMode == AuthMode.signUp;

  void _switchAuthMode() {
    setState(() {
      if (isLogin()) {
        _authMode = AuthMode.signUp;
      } else {
        _authMode = AuthMode.login;
      }
    });
  }

  Future<void> _submit() async {
    bool isValid = _formkey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    _formkey.currentState?.save();

    setState(() {
      _isLoading = true;
    });

    Auth auth = Provider.of<Auth>(context, listen: false);

    if (isLogin()) {
      // login
      await auth.signIn(_authData['email']!, _authData['password']!);
    } else {
      // registrar
      await auth.signUp(_authData['email']!, _authData['password']!);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
          height: isLogin() ? 310 : 400,
          width: deviceSize.width * 0.75,
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formkey,
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
                if (isSignUp())
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Confirmar senha'),
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    validator: isLogin()
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
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 8),
                    ),
                    child: Text(isLogin() ? 'ENTRAR' : 'REGISTRAR'),
                  ),
                const Spacer(),
                TextButton(
                    onPressed: _switchAuthMode,
                    child: Text(
                        isLogin() ? 'Deseja registrar?' : 'Já possui conta?'))
              ],
            ),
          )),
    );
  }
}
