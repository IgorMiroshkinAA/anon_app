import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:4000/api';

  static Future<String> requestCode(String email) async {
    final url = Uri.parse('$baseUrl/auth/request-code');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['token'];
      } else if (response.statusCode == 429) {
        throw Exception('Слишком много запросов. Попробуйте позже.');
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Ошибка отправки кода');
      }
    } catch (e) {
      throw Exception('Ошибка запроса кода: $e');
    }
  }

  static Future<String> resendCode(String email) async {
    final url = Uri.parse('$baseUrl/auth/resend-code');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['token'];
      } else if (response.statusCode == 429) {
        throw Exception('Слишком много запросов. Попробуйте позже.');
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Ошибка повторной отправки кода');
      }
    } catch (e) {
      throw Exception('Ошибка запроса повторного кода: $e');
    }
  }

  static Future<String> verifyCode(String tempToken, String code) async {
    final url = Uri.parse('$baseUrl/auth/verify-code');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $tempToken',
        },
        body: json.encode({'code': code}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['token'];
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Неверный код');
      }
    } catch (e) {
      throw Exception('Ошибка проверки кода: $e');
    }
  }

  static Future<String> setNickname(String accessToken, String nickname) async {
    final url = Uri.parse('$baseUrl/auth/set-nickname');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: json.encode({'nickname': nickname}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['token'];
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Ошибка при установке никнейма');
    }
  }

  static Future<void> setAge(String accessToken, int age) async {
    final url = Uri.parse('$baseUrl/auth/set-age');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode({'age': age}),
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Ошибка при установке возраста');
      }
    } catch (e) {
      throw Exception('Ошибка запроса возраста: $e');
    }
  }

  static Future<String> setPassword(String accessToken, String password, String confirm) async {
    final url = Uri.parse('$baseUrl/auth/set-password');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode({'password': password, 'confirm': confirm}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['token'];
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Ошибка при установке пароля');
      }
    } catch (e) {
      throw Exception('Ошибка запроса пароля: $e');
    }
  }

  static Future<Map<String, dynamic>> initAuth(String email) async {
    final url = Uri.parse('$baseUrl/auth/init');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Ошибка инициализации');
      }
    } catch (e) {
      throw Exception('Ошибка запроса initAuth: $e');
    }
  }

  static Future<String> verifyPassword(String accessToken, String password) async {
    final url = Uri.parse('$baseUrl/auth/verify-password');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode({'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['token'];
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Неверный пароль');
      }
    } catch (e) {
      throw Exception('Ошибка проверки пароля: $e');
    }
  }

  static Future<Map<String, dynamic>> getUser(String accessToken) async {
    final url = Uri.parse('$baseUrl/auth/user');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Ошибка получения пользователя: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка запроса getUser: $e');
    }
  }

  // static Future<void> logout() async {
  //   // Заглушка — можно реализовать вызов API при необходимости
  //   await Future.delayed(const Duration(milliseconds: 200));
  // }

  static Future<List<dynamic>> getActiveChats(String accessToken) async {
    final url = Uri.parse('$baseUrl/chats/active');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data is List ? data : [];
    } else {
      throw Exception('Ошибка загрузки активных чатов: ${response.statusCode}');
    }
  }

  static Future<List<dynamic>> getArchiveChats(String accessToken) async {
    final url = Uri.parse('$baseUrl/chats/archive');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data is List ? data : [];
    } else {
      throw Exception('Ошибка загрузки архивных чатов: ${response.statusCode}');
    }
  }

  static Future<void> selectPlan(String accessToken, int planId) async {
    final url = Uri.parse('$baseUrl/payment/select');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: json.encode({'planId': planId}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      log('✅ План выбран: ${data['message']}');
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Ошибка при выборе тарифа');
    }
  }
}