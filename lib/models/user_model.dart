class AppUser {
  final String uid;
  final String email;
  final String name;
  final String university;
  final String department;
  final String semester;
  final String profilePicUrl;

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    this.university = '',
    this.department = '',
    this.semester = '',
    this.profilePicUrl = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'university': university,
      'department': department,
      'semester': semester,
      'profilePicUrl': profilePicUrl,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      university: map['university'] ?? '',
      department: map['department'] ?? '',
      semester: map['semester'] ?? '',
      profilePicUrl: map['profilePicUrl'] ?? '',
    );
  }
}
