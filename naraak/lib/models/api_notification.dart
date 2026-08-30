class ApiNotification {
  const ApiNotification(
      {required this.id,
      required this.type,
      required this.title,
      required this.body,
      required this.read,
      required this.createdAt,
      this.routeTarget});
  final String id;
  final String type;
  final String title;
  final String body;
  final bool read;
  final DateTime createdAt;
  final String? routeTarget;

  factory ApiNotification.fromJson(Map<String, dynamic> json) =>
      ApiNotification(
        id: json['notificationId'] as String,
        type: json['type'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        read: json['read'] as bool,
        createdAt: DateTime.parse(json['createdAt'] as String),
        routeTarget: json['routeTarget'] as String?,
      );

  ApiNotification copyWith({bool? read}) => ApiNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      read: read ?? this.read,
      createdAt: createdAt,
      routeTarget: routeTarget);
}
