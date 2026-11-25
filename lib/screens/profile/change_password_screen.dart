import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/user_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving || !_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final error = await context
        .read<UserProvider>()
        .changePassword(_current.text, _next.text);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error ?? 'Đã đổi mật khẩu.'),
      backgroundColor: error == null ? AppColors.secondary : AppColors.error,
    ));
    if (error == null) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Thay đổi mật khẩu')),
        body: Form(
          key: _form,
          child: ListView(padding: const EdgeInsets.all(16), children: [
            TextFormField(
                controller: _current,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Mật khẩu hiện tại'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nhập mật khẩu hiện tại.' : null),
            TextFormField(
                controller: _next,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
                validator: (v) => v == null || v.length < 8
                    ? 'Mật khẩu tối thiểu 8 ký tự.'
                    : null),
            TextFormField(
                controller: _confirm,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Nhập lại mật khẩu mới'),
                validator: (v) =>
                    v != _next.text ? 'Mật khẩu nhập lại chưa khớp.' : null),
            const SizedBox(height: 20),
            FilledButton(
                onPressed: _saving ? null : _submit,
                child: Text(_saving ? 'Đang lưu...' : 'Cập nhật mật khẩu')),
          ]),
        ),
      );
}
