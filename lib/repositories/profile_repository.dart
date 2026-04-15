import '../models/wash_models.dart';

abstract class ProfileRepository {
  UserProfile getProfile();
  UserProfile saveProfile(UserProfile profile);
  UserProfile syncLoginEmail(String email);
}
