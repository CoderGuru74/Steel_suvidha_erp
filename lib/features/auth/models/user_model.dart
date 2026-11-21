import '../../../core/constants/app_roles.dart';

class UserModel {
  final String id;
  final String name;
  final String identifier;
  final UserRole role;

  const UserModel({
    required this.id,
    required this.name,
    required this.identifier,
    required this.role,
  });
}
