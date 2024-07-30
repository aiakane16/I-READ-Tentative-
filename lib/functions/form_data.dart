class FormData {
  static final FormData _instance = FormData._internal();

  factory FormData() {
    return _instance;
  }

  FormData._internal();

  String fullName = '';
  String strand = '';
  String birthday = '';
  String address = '';
  String email = ''; // Add email field
  String username = ''; // Add username field
  String password = ''; // Add password field
}
