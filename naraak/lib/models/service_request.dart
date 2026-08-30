/// Shared shape for the request-based services (Hajj Certificate, Fee
/// Exemption, Mobile Unit, PHC Research, etc.) — matches the common
/// requestId/status pattern across the Phase 5 API spec, Section 3.
class ServiceRequest {
  final String id;
  final String serviceName;
  final String
      status; // 'submitted' | 'processing' | 'approved' | 'rejected' | 'ready'
  final DateTime submittedAt;
  final String? note;
  final String? attachmentName;

  const ServiceRequest({
    required this.id,
    required this.serviceName,
    required this.status,
    required this.submittedAt,
    this.note,
    this.attachmentName,
  });

  /// 'rejected' requests, and 'submitted' requests carrying a note that
  /// explains what's missing, surface under the "Action Needed" filter on
  /// the Pending Requests screen (Phase 6 §5, request tracking statuses).
  bool get requiresAction => status == 'rejected';

  bool get isOpen => status == 'submitted' || status == 'processing';

  bool get isCompleted => status == 'approved' || status == 'ready';

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: (json['requestId'] ?? json['id']) as String,
      serviceName: (json['serviceType'] ?? json['serviceName']) as String,
      status: json['status'] as String,
      submittedAt:
          DateTime.parse((json['createdAt'] ?? json['submittedAt']) as String),
      note: (json['summary'] ?? json['note']) as String?,
      attachmentName: json['attachmentName'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'serviceName': serviceName,
        'status': status,
        'submittedAt': submittedAt.toIso8601String(),
        'note': note,
        'attachmentName': attachmentName,
      };
}
