import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/exception/auth_expection.dart';
import 'package:shop/models/auth.dart';

enum AuthMode { login, signUp }

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm>
    with SingleTickerProviderStateMixin {
  AuthMode _authMode = AuthMode.login;
  final TextEditingController _passwordController = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  bool _isLoading = false;

  final Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  AnimationController? _animationController;
  Animation<double>? _opacityAnimation;
  Animation<Offset>? _slideAnimation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController!, curve: Curves.linear));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1.5), end: const Offset(0, 0))
            .animate(CurvedAnimation(
                parent: _animationController!, curve: Curves.linear));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _animationController?.dispose();
  }

  bool isLogin() => _authMode == AuthMode.login;
  bool isSignUp() => _authMode == AuthMode.signUp;

  void _switchAuthMode() {
    setState(() {
      if (isLogin()) {
        _authMode = AuthMode.signUp;
        _animationController?.forward();
      } else {
        _authMode = AuthMode.login;
        _animationController?.reverse();
      }
    });
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ocorreu um erro'),
        content: Text(msg),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fechar'))
        ],
      ),
    );
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

    try {
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
    } on AuthException catch (error) {
      _showErrorDialog(error.toString());
    } catch (error) {
      _showErrorDialog('Ocorreu um erro inesperado.');
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
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
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
              AnimatedContainer(
                constraints: BoxConstraints(
                  minHeight: isLogin() ? 0 : 60,
                  maxHeight: isLogin() ? 0 : 120,
                ),
                duration: const Duration(milliseconds: 300),
                curve: Curves.linear,
                child: FadeTransition(
                  opacity: _opacityAnimation!,
                  child: SlideTransition(
                    position: _slideAnimation!,
                    child: TextFormField(
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
                  ),
                ),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
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
        ),
      ),
    );
  }
}
