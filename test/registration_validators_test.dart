import 'package:flutter_test/flutter_test.dart';
import 'package:finance_management/utils/registration_validators.dart';

void main() {
  test('Họ tên bắt buộc và chấp nhận tiếng Việt', () {
    expect(RegistrationValidators.name('  '), isNotNull);
    expect(RegistrationValidators.name('Nguyễn An'), isNull);
    expect(RegistrationValidators.name('LE THI THAO'), isNull);
    expect(RegistrationValidators.name('Nguyễn  An'), isNull);
    expect(RegistrationValidators.name('An123'), isNotNull);
  });

  test('Gmail kiểm tra đúng định dạng và chỉ nhận gmail.com', () {
    for (final email in [
      '',
      'abc',
      'a@',
      '@email.com',
      'a@email',
      'a b@email.com',
      'a..b@email.com',
      '.a@email.com',
      'a@-mail.com',
      'a@mail..com',
      'a@@mail.com'
    ]) {
      expect(RegistrationValidators.gmail(email), isNotNull, reason: email);
    }
    expect(RegistrationValidators.gmail('ten@yahoo.com'), isNotNull);
    expect(
        RegistrationValidators.gmail('ten@student.hcmute.edu.vn'), isNotNull);
    for (final email in [
      'ten@gmail.com',
      'ten+demo@gmail.com',
      ' first.last@GMAIL.COM '
    ]) {
      expect(RegistrationValidators.gmail(email), isNull, reason: email);
    }
  });

  test('Số điện thoại chuẩn hóa khoảng cách và hỗ trợ +84', () {
    expect(RegistrationValidators.normalizePhone('0912 345 678'), '0912345678');
    expect(RegistrationValidators.phone('0912 345 678'), isNull);
    expect(RegistrationValidators.phone('+84 912 345 678'), isNull);
    expect(
        RegistrationValidators.normalizePhone('+84 912 345 678'), '0912345678');
    for (final phone in [
      '',
      '123',
      '09123456789',
      '0123456789',
      '0912abc678'
    ]) {
      expect(RegistrationValidators.phone(phone), isNotNull);
    }
  });

  test('Tên tài khoản giữ quy tắc 3–30 ký tự không dấu', () {
    for (final username in [
      '',
      'ab',
      'tên',
      'ten tai khoan',
      'user@name',
      List.filled(31, 'a').join()
    ]) {
      expect(RegistrationValidators.username(username), isNotNull);
    }
    expect(RegistrationValidators.username('an.nguyen_01'), isNull);
  });

  test('Mật khẩu đủ 8 ký tự và xác nhận phải khớp nguyên văn', () {
    expect(RegistrationValidators.password('        '), isNotNull);
    expect(RegistrationValidators.password('1234567'), isNotNull);
    expect(RegistrationValidators.password('12345678'), isNotNull);
    expect(RegistrationValidators.password('abcdefgh'), isNotNull);
    expect(RegistrationValidators.password('Abc12345'), isNull);
    expect(RegistrationValidators.confirmPassword('', 'Abc12345'), isNotNull);
    expect(RegistrationValidators.confirmPassword('Abc12345 ', 'Abc12345'),
        isNotNull);
    expect(
        RegistrationValidators.confirmPassword('Abc12345', 'Abc12345'), isNull);
  });
}
