bool isValidPhone(String phone) {
  final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');

  return phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[\s\-()]'), ''));
}

class InvalidPhoneException implements Exception {}
