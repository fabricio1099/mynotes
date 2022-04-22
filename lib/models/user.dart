import 'package:flutter/foundation.dart';

const idColumn = 'id';
const emailColumn = 'email';

@immutable
class User {
  static const tableName = 'user';

  final int id;
  final String email;

  const User({
    required this.id,
    required this.email,
  });

  //representation type of a Row in database -> Map<String, Object?>
  User.fromDbRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;
  
  @override
  String toString() => 'User, ID = $id, email = $email';

  @override bool operator ==(covariant User other) => other.id == id;

  @override
  int get hashCode => id.hashCode;
}