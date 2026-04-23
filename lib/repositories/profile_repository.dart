import '../models/wash_models.dart';

abstract class ProfileRepository {
  Future<UserProfile?> getProfile(String uid);
  Future<UserProfile> updateProfile(UserProfile profile);
  Future<void> updateAddress(String uid, String address);
  Stream<UserProfile?> watchProfile(String uid);
}
