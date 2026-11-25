import 'package:shared_preferences/shared_preferences.dart';
import '../models/tracker.dart';

class StorageService {
  static const _trackersKey = 'trackers';
  static const _profileKey = 'profile';

  static Future<List<Tracker>> getTrackers() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_trackersKey);
    if (json == null || json.isEmpty) return [];
    return Tracker.listFromJson(json);
  }

  static Future<void> saveTrackers(List<Tracker> trackers) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_trackersKey, Tracker.listToJson(trackers));
  }

  static Future<Profile> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_profileKey);
    if (json == null || json.isEmpty) return Profile();
    return Profile.fromJsonString(json);
  }

  static Future<void> saveProfile(Profile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, profile.toJsonString());
  }
}
