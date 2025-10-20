import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class AuthService {
  // static const String baseUrl = 'http://89.109.34.227:3000/api';
  static const String baseUrl = 'http://10.0.2.2:4000/api';

  static Future<String> requestCode(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/request-code'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['token']; // Возвращаем временный токен
      } else if (response.statusCode == 429) {
        throw Exception('Слишком много запросов. Попробуйте позже.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Ошибка отправки кода');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<String> resendCode(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/resend-code'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['token']; // Возвращаем временный токен
      } else if (response.statusCode == 429) {
        throw Exception('Слишком много запросов. Попробуйте позже.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Ошибка отправки кода');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<String> verifyCode(String tempToken, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-code'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $tempToken',
        },
        body: json.encode({'code': code}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['token']; // ← accessToken
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Неверный код');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<String> setNickname(String accessToken, String nickname) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/set-nickname'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: json.encode({'nickname': nickname}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['token'];
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Ошибка при установке никнейма');
    }
  }


  static Future<void> setAge(String finalToken, int age) async {
    log(finalToken);
    try {
      await http.post(
        Uri.parse('$baseUrl/auth/set-age'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $finalToken',
        },
        body: json.encode({'age': age}),
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<String> setPassword(
    String finalToken,
    String password,
    String confirm,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/set-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $finalToken',
        },
        body: json.encode({'password': password, "confirm": confirm}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['token'];
      }
    } catch (e) {
      rethrow;
    }
    return finalToken;
  }

  static Future<String> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/check-email'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'password': password, "email": email}),
      );
      if (response.statusCode == 401) {
        return "registration";
      } else if (response.statusCode == 402 && password == '123456789') {
        return "login";
      } else if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['token'];
      } else {
        throw Exception('Неверный пароль');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getUser(String? finalToken) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $finalToken',
        },
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData;
      } else {
        throw Exception('Нет авторизации');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Ничего не делаем
  }

  static Future<List<dynamic>> getActiveChats(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/chats/active'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data ?? []; // Предполагая, что ответ содержит поле 'chats'
    } else {
      throw Exception('Failed to load active chats: ${response.statusCode}');
    }
  }

  static Future<List<dynamic>> getArchiveChats(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/chats/archive'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data ?? []; // Предполагая, что ответ содержит поле 'chats'
    } else {
      return [];
    }
  }

  // Выбор плана подписки
  static Future<void> selectPlan(String token, int planId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payment/select'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'planId': planId}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print('План успешно выбран: ${responseData['message']}');
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Ошибка при выборе тарифа');
    }
  }
}
