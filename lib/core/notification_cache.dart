import 'package:shared_preferences/shared_preferences.dart';
import 'package:staybay/models/notification_model.dart';

class NotificationCache {
  static const _shownIdsKey = 'shown_notification_ids';

  static Future<List<String>> getShownIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_shownIdsKey) ?? [];
  }

  static Future<List<NotificationModel>> getNotShowedNotifications(
    List<NotificationModel> newIds,
  ) async {
    final List<String> shownIds = await getShownIds();
    final List<NotificationModel> toShow = [];

    for (final n in newIds) {
      if (!shownIds.contains(n.id.toString())) {
        toShow.add(n);
        addShownId(n.id);
      }
    }
    return toShow;
  }

  static Future<void> addShownId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_shownIdsKey) ?? [];

    if (!list.contains(id.toString())) {
      list.add(id.toString());
      await prefs.setStringList(_shownIdsKey, list);
    }
  }

  static Future<void> clearShownIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_shownIdsKey);
  }
}
