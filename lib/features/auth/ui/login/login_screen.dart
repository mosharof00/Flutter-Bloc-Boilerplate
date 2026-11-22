import 'dart:async';

import 'package:enterprise_mvvm/core/error/failure_message.dart';
import 'package:enterprise_mvvm/core/theme/app_tokens.dart';
import 'package:enterprise_mvvm/core/ui/widgets/app_button.dart';
import 'package:enterprise_mvvm/core/ui/widgets/app_text_field.dart';
import 'package:enterprise_mvvm/core/ui/widgets/gradient_scaffold.dart';
import 'package:enterprise_mvvm/features/auth/ui/login/login_state.dart';
import 'package:enterprise_mvvm/features/auth/ui/login/login_view_model.dart';
import 'package:enterprise_mvvm/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({required this.viewModel, super.key});

  final LoginViewModel viewModel;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    unawaited(
      widget.viewModel.submit(email: _email.text, password: _password.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GradientScaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: BlocBuilder<LoginViewModel, LoginState>(
                bloc: widget.viewModel,
                builder: (BuildContext context, LoginState state) {
                  final loading = state is LoginLoading;
                  final failure = state is LoginFailure ? state.failure : null;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        l10n.loginTitle,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l10n.loginHint,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppTextField(
                        key: const Key('login_email'),
                        controller: _email,
                        label: l10n.emailLabel,
                        hintText: l10n.emailHint,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const <String>[AutofillHints.email],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        key: const Key('login_password'),
                        controller: _password,
                        label: l10n.passwordLabel,
                        hintText: l10n.passwordHint,
                        obscureText: true,
                        canReveal: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        autofillHints: const <String>[AutofillHints.password],
                      ),
                      if (failure != null) ...<Widget>[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          key: const Key('login_error'),
                          failureMessage(l10n, failure),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      AppButton(
                        key: const Key('login_submit'),
                        label: l10n.loginAction,
                        isLoading: loading,
                        onPressed: loading ? null : _submit,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
