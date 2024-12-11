import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:message_in_a_botlle/models/user_model.dart';

// String _url = "https://48mz9gbq-5000.inc1.devtunnels.ms";
String _url = "https://api.messageinabotlle.app/";

class UserSearchState {
  final List<User> allUsers;
  final List<User>? results;
  final List<User>? visibleUsers;
  final User? user;
  final bool isLoading;
  final String? error;

  UserSearchState({
    this.allUsers = const [],
    this.results,
    this.visibleUsers,
    this.user,
    this.isLoading = false,
    this.error,
  });

  UserSearchState copyWith({
    List<User>? allUsers,
    List<User>? results,
    List<User>? visibleUsers,
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return UserSearchState(
      allUsers: allUsers ?? this.allUsers,
      results: results ?? this.results,
      visibleUsers: visibleUsers ?? this.visibleUsers,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class UserSearchNotifier extends StateNotifier<UserSearchState> {
  UserSearchNotifier() : super(UserSearchState());

  final _storage = const FlutterSecureStorage();

  Future<void> fetchUsers() async {
    state = state.copyWith(isLoading: true);

    try {
      final response = await http.get(Uri.parse('$_url/users'));
      if (response.statusCode == 200) {
        final List<dynamic> usersJson = jsonDecode(response.body);
        final users = usersJson.map((json) => User.fromJson(json)).toList();
        state = state.copyWith(allUsers: users, isLoading: false);
      } else {
        state = state.copyWith(error: 'Failed to load users', isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void filterUsers(String searchTerm) {
    final searchParts = searchTerm.trim().toLowerCase().split(' ');

    final filtered = state.allUsers.where((user) {
      final fullName = '${user.firstName} ${user.lastName}'.toLowerCase();
      final matchesName = searchParts.every((part) => fullName.contains(part));
      final matchesMobile = searchTerm.trim() == user.mobile;

      return matchesName || matchesMobile;
    }).toList();

    state = state.copyWith(results: filtered);
  }

  Future<void> saveVisibleUser(String userId) async {
    try {
      final savedUsers = await _storage.read(key: 'visibleUsers');
      final visibleUserIds = savedUsers != null
          ? List<String>.from(jsonDecode(savedUsers))
          : <String>[];

      if (!visibleUserIds.contains(userId)) {
        visibleUserIds.add(userId);
        await _storage.write(
            key: 'visibleUsers', value: jsonEncode(visibleUserIds));
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to save visible user: $e');
    }
  }

  Future<void> fetchVisibleUsers() async {
    try {
      if (state.allUsers.isEmpty) {
        await fetchUsers();
      }

      final savedUsers = await _storage.read(key: 'visibleUsers');
      if (savedUsers != null) {
        final visibleUserIds = List<String>.from(jsonDecode(savedUsers));

        final visibleUsers = state.allUsers
            .where((user) => visibleUserIds.contains(user.id))
            .toList();

        state = state.copyWith(visibleUsers: visibleUsers);
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to fetch visible users: $e');
    }
  }

  Future<void> removeVisibleUser(String userId) async {
    try {
      final savedUsers = await _storage.read(key: 'visibleUsers');
      if (savedUsers != null) {
        final visibleUserIds = List<String>.from(jsonDecode(savedUsers));
        visibleUserIds.remove(userId);

        await _storage.write(
            key: 'visibleUsers', value: jsonEncode(visibleUserIds));

        final updatedVisibleUsers =
            state.visibleUsers?.where((user) => user.id != userId).toList();

        state = state.copyWith(visibleUsers: updatedVisibleUsers);
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to remove visible user: $e');
    }
  }
}

final searchProvider =
    StateNotifierProvider<UserSearchNotifier, UserSearchState>((ref) {
  return UserSearchNotifier();
});
