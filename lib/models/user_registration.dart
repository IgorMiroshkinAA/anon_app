class UserRegistration {
  String? name;
  String? email;
  int? age;
  String? password;
  int? id;
  int? levelSubscription;

  UserRegistration({
    this.name,
    this.email,
    this.age,
    this.password,
    required this.id,
    this.levelSubscription = 1, // По умолчанию бесплатный план
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'age': age,
    'password': password,
    'id': id,
    'levelSubscription': levelSubscription,
  };

  void reset() {
    name = null;
    email = null;
    age = null;
    password = null;
    levelSubscription = 1;
  }
}
