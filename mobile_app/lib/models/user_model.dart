class User {
  final String? id;
  final String name;
  final String phone;
  final String email;
  final String voicePreference; // 'jarvis' or 'friday'

  User({
    this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.voicePreference = 'jarvis',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'voicePreference': voicePreference,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      voicePreference: json['voicePreference'] ?? 'jarvis',
    );
  }
}
