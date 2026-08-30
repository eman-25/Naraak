class MedicalReport {
  const MedicalReport({
    required this.id,
    required this.category,
    required this.reportType,
    required this.consultantName,
    required this.date,
    required this.status,
    this.documentReference,
  });

  final String id;
  final String category;
  final String reportType;
  final String consultantName;
  final DateTime date;
  final String status;
  final String? documentReference;

  factory MedicalReport.fromJson(Map<String, dynamic> json) => MedicalReport(
        id: json['reportId'] as String,
        category: json['category'] as String,
        reportType: json['reportType'] as String,
        consultantName: json['consultantName'] as String,
        date: DateTime.parse(json['date'] as String),
        status: json['status'] as String,
        documentReference: json['documentReference'] as String?,
      );
}
