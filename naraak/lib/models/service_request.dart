/// Shared shape for the request-based services (Hajj Certificate, Fee
/// Exemption, Mobile Unit, PHC Research, etc.) — matches the common
/// requestId/status pattern across the Phase 5 API spec, Section 3.
class ServiceRequest {
  final String id;
  final String serviceName;
  final String status; // 'submitted' | 'processing' | 'approved' | 'rejected' | 'ready'
  final DateTime submittedAt;
  final String? note;

  const ServiceRequest({
    required this.id,
    required this.serviceName,
    required this.status,
    required this.submittedAt,
    this.note,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'] as String,
      serviceName: json['serviceName'] as String,
      status: json['status'] as String,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'serviceName': serviceName,
        'status': status,
        'submittedAt': submittedAt.toIso8601String(),
        'note': note,
      };
}