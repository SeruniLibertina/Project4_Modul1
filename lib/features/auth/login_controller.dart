class LoginController {
  final Map<String, String> _users = {
    "admin": "123",
    "budi": "456",
  };

  int _attempt = 0;

  bool login(String username, String password) {
    if (_users.containsKey(username) &&
        _users[username] == password) {
      _attempt = 0;
      return true;
    } else {
      _attempt++;
      return false;
    }
  }

  int get attempt => _attempt;
}
