import 'package:flutter/material.dart';
import 'package:quick_social/models/user_model.dart';
import 'package:quick_social/services/user_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  final UserApiService _apiService = UserApiService();

  final Map<String, UserAccount> _users = {};
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, UserAccount> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchUserProfile(String uuid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _apiService.getUserProfile(uuid);

      _users[uuid] = user!;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  UserAccount? getUser(String uuid) {
    return _users[uuid];
  }
}
