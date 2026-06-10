/// In-memory user session — no persistent storage required by the spec.
class UserSession {
  String? _userId;
  String? _userName;

  String? get userId => _userId;
  String? get userName => _userName;
  bool get isLoggedIn => _userId != null;

  void setUser(String id, String name) {
    _userId = id;
    _userName = name;
  }

  void clear() {
    _userId = null;
    _userName = null;
  }
}
