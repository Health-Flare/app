import 'package:health_flare/data/models/profile_isar.dart';
import 'package:health_flare/models/profile.dart';

/// Test fixtures for Profile-related data.
///
/// Use these fixtures to create consistent test data across tests.
class ProfileFixtures {
  ProfileFixtures._();

  /// A simple profile with just a name.
  static Profile get simple => Profile(
        id: 1,
        name: 'Test User',
      );

  /// A profile with all fields populated.
  static Profile get complete => Profile(
        id: 2,
        name: 'Sarah',
        dateOfBirth: DateTime(1990, 5, 15),
        avatarPath: '/path/to/avatar.jpg',
      );

  /// Multiple profiles for testing profile switching.
  static List<Profile> get multipleProfiles => [
        Profile(id: 1, name: 'Sarah'),
        Profile(id: 2, name: 'Dad'),
        Profile(id: 3, name: 'Mom'),
      ];

  /// Profile Isar models for database seeding.
  static ProfileIsar get simpleIsar => ProfileIsar()
    ..id = 1
    ..name = 'Test User';

  static ProfileIsar get completeIsar => ProfileIsar()
    ..id = 2
    ..name = 'Sarah'
    ..dateOfBirth = DateTime(1990, 5, 15)
    ..avatarPath = '/path/to/avatar.jpg';

  static List<ProfileIsar> get multipleProfilesIsar => [
        ProfileIsar()
          ..id = 1
          ..name = 'Sarah',
        ProfileIsar()
          ..id = 2
          ..name = 'Dad',
        ProfileIsar()
          ..id = 3
          ..name = 'Mom',
      ];
}
