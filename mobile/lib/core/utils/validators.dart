class Validators {
  const Validators._();

  static String? email(String? value) {
    if (value == null || value.isEmpty) return '이메일을 입력해주세요.';
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    if (!regex.hasMatch(value)) return '올바른 이메일 형식을 입력해주세요.';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return '비밀번호를 입력해주세요.';
    if (value.length < 8) return '비밀번호는 8자 이상이어야 합니다.';
    return null;
  }

  static String? required(String? value, [String fieldName = '이 항목']) {
    if (value == null || value.trim().isEmpty) return '$fieldName을(를) 입력해주세요.';
    return null;
  }

  static String? maxLength(String? value, int max, [String fieldName = '이 항목']) {
    if (value != null && value.length > max) {
      return '$fieldName은(는) $max자 이하여야 합니다.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String? newPassword) {
    if (value == null || value.isEmpty) return '비밀번호 확인을 입력해주세요.';
    if (value != newPassword) return '비밀번호가 일치하지 않습니다.';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return null;
    final regex = RegExp(r'^01[016789]-?\d{3,4}-?\d{4}$');
    if (!regex.hasMatch(value)) return '올바른 전화번호 형식을 입력해주세요.';
    return null;
  }
}