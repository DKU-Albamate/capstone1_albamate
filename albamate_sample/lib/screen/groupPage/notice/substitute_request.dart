// 대타 요청 서버 응답을 위한 모델

class SubstituteRequest {
  final String id;
  final String groupId;
  final String requesterName; // 요청자 이름 (requester_name)
  final String? substituteName; // 대타 이름 (substitute_name, 수락 시)
  final String shiftDate; // 근무 날짜 (shift_date)
  final String startTime; // 시작 시간 (start_time)
  final String endTime; // 종료 시간 (end_time)
  final String reason; // 요청 사유 (reason)
  final String status; // 요청 상태 (status: PENDING, IN_REVIEW, APPROVED, REJECTED)
  final String createdAt;
  final String? approvedAt; // 승인 시점

  SubstituteRequest({
    required this.id,
    required this.groupId,
    required this.requesterName,
    this.substituteName,
    required this.shiftDate,
    required this.startTime,
    required this.endTime,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.approvedAt,
  });

  factory SubstituteRequest.fromJson(Map<String, dynamic> json) {
    return SubstituteRequest(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      requesterName: json['requester_name'] as String,
      substituteName: json['substitute_name'] as String?,
      shiftDate: json['shift_date'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      reason: json['reason'] as String,
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
      approvedAt: json['approved_at'] as String?,
    );
  }
}