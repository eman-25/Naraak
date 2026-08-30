import 'package:flutter/foundation.dart';

/// Tracks which notification IDs have been read, in memory for this demo
/// session. Backs both the Notifications screen's read/unread state and
/// the top bar's unread badge, so they can't disagree.
class NotificationsReadProvider extends ChangeNotifier {
  final Set<String> _readIds = {};

  bool isRead(String id) => _readIds.contains(id);

  void markRead(String id) {
    if (_readIds.add(id)) notifyListeners();
  }

  void markAllRead(Iterable<String> ids) {
    final before = _readIds.length;
    _readIds.addAll(ids);
    if (_readIds.length != before) notifyListeners();
  }

  int unreadCount(Iterable<String> ids) =>
      ids.where((id) => !_readIds.contains(id)).length;
}
