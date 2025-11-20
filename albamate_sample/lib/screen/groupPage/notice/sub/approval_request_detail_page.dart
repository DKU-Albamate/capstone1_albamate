import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
// 💡 SubstituteRequest 모델 파일 경로 확인
import 'package:albamate_sample/screen/groupPage/notice/substitute_request.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

// ======================================================================
// App Colors (일관성 유지를 위해 정의)
// ======================================================================

class AppColors {
  static const Color appPrimary = Color(0xFF007AFF);
  static const Color approvalPrimary = Color(0xFF006FFD);
  static const Color appBackground = Color(0xFFF6F6F8);
  static const Color appTextPrimary = Color(0xFF1C1C1E);
  static const Color appTextSecondary = Color(0xFF8E8E93);
  static const Color white = Colors.white;
  static const Color rejectColor = Color(0xFFDC2626); // Danger Color
  static const Color borderGray = Color(0xFFEEEEEE); // Light gray for borders/shadows
  static const Color sectionTitleColor = Color(0xFF586274);
}

// ======================================================================
// ApprovalRequestDetailPage (사장님 상세 승인 페이지)
// ======================================================================

class ApprovalRequestDetailPage extends StatefulWidget {
  // 💡 상세 정보를 불러오기 위한 requestId만 받습니다.
  final String requestId;

  const ApprovalRequestDetailPage({required this.requestId, super.key});

  @override
  State<ApprovalRequestDetailPage> createState() => _ApprovalRequestDetailPageState();
}

class _ApprovalRequestDetailPageState extends State<ApprovalRequestDetailPage> {
  // 💡 데이터를 비동기로 불러오기 위한 Future 변수
  Future<SubstituteRequest>? _requestDetailFuture;
  final String _backendBaseUrl = 'https://backend-vgbf.onrender.com/api/substitute/requests';

  @override
  void initState() {
    super.initState();
    _requestDetailFuture = _fetchShiftRequestDetail(widget.requestId);
  }

  // 1. 요청 ID를 사용하여 상세 정보를 불러오는 함수 (HTTP GET)
  Future<SubstituteRequest> _fetchShiftRequestDetail(String id) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();

    final response = await http.get(
      Uri.parse('$_backendBaseUrl/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      if (data == null) {
        throw Exception('요청 상세 정보가 응답 데이터 필드에 없습니다.');
      }
      return SubstituteRequest.fromJson(data);
    } else {
      final errorBody = json.decode(utf8.decode(response.bodyBytes));
      throw Exception('요청 상세 정보 로딩 실패: 상태 코드 ${response.statusCode}, 메시지: ${errorBody['message'] ?? '알 수 없는 서버 오류'}');
    }
  }

  // 2. 요청 승인/거절 처리 함수 (HTTP PUT)
Future<void> _handleApproval(String requestId, bool isApproved, String requesterName) async {
  if (!mounted) return;

  setState(() {
    _requestDetailFuture = Future.error('Processing...');
  });

  // 💡 서버 명세에 맞게 final_status 설정
  final String finalStatus = isApproved ? 'APPROVED' : 'REJECTED';
  final String actionName = isApproved ? '승인' : '거절';

  try {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();

    // 💡 1. URL 경로 변경: /:request_id/manage 로 통일
    final Uri uri = Uri.parse('$_backendBaseUrl/$requestId/manage');

    // 💡 2. 요청 바디 변경: final_status 필드만 사용
    final putData = {
      'final_status': finalStatus,
    };

    final response = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(putData),
    );

    // =========================================================
    // 서버 응답 처리 로직 (이전 버전에서 안정화됨)
    // =========================================================
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('대타 요청이 성공적으로 $actionName 처리되었습니다!')),
      );
      Navigator.pop(context, true);
    } else {
      String errorMessage;
      String responseBodyString = utf8.decode(response.bodyBytes);

      try {
        final responseBody = jsonDecode(responseBodyString);
        // 서버에서 정의한 에러 메시지를 사용합니다.
        errorMessage = responseBody['message'] ?? '$actionName 처리 중 알 수 없는 서버 오류가 발생했습니다.';
      } catch (e) {
        // JSON 파싱 실패 시 (HTML 응답 등)
        errorMessage = '서버 응답 오류 (상태: ${response.statusCode}). 서버 로그를 확인해 주세요.';
      }
      throw Exception(errorMessage);
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$actionName 처리 중 오류 발생: ${e.toString().split(':').last.trim()}')),
    );
    if (mounted) {
        setState(() {
          _requestDetailFuture = _fetchShiftRequestDetail(widget.requestId);
        });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        title: const Text('대타 승인 상세', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.appTextPrimary)),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // 💡 FutureBuilder로 데이터 로딩 처리
      body: FutureBuilder<SubstituteRequest>(
        future: _requestDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.approvalPrimary));
          } else if (snapshot.hasError) {
             // 'Processing' 오류 메시지는 로딩 상태로 처리
            return Center(child: Text(snapshot.error.toString().contains('Processing') ? '요청 처리 중...' : snapshot.error.toString(), textAlign: TextAlign.center, style: TextStyle(color: AppColors.rejectColor)));
          } else if (snapshot.hasData) {
            final request = snapshot.data!;
            return _buildContent(context, request);
          }
          return const Center(child: Text('요청 정보를 찾을 수 없습니다.', style: TextStyle(color: AppColors.appTextSecondary)));
        },
      ),
    );
  }

  // 3. UI Content Builder
  Widget _buildContent(BuildContext context, SubstituteRequest request) {
    // 💡 날짜/시간 포맷팅
    final DateTime shiftStart = DateTime.parse('${request.shiftDate} ${request.startTime}');
    final DateTime shiftEnd = DateTime.parse('${request.shiftDate} ${request.endTime}');
    final String dateDisplay = DateFormat('yyyy년 M월 d일 (E)', 'ko').format(shiftStart);
    final String timeDisplay = '${DateFormat('HH:mm').format(shiftStart)} ~ ${DateFormat('HH:mm').format(shiftEnd)}';

    return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0), // p-6
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. 근무 변경 정보 섹션
                  _buildSectionTitle('근무 변경 정보'),
                  _buildProfileSection(request),

                  const SizedBox(height: 24),

                  // 2. 변경될 근무 섹션
                  _buildSectionTitle('변경될 근무'),
                  _buildScheduleDetails(dateDisplay, timeDisplay),

                  const SizedBox(height: 24),

                  // 3. 요청 사유 섹션
                  _buildSectionTitle('요청 사유'),
                  _buildReasonSection(request.reason),
                ],
              ),
            ),
          ),
          // 4. Action Buttons (Sticky Footer)
          _buildActionButtons(context, request),
        ],
      );
  }

  // 섹션 제목 위젯 (사용자 스타일 유지)
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.sectionTitleColor,
        ),
      ),
    );
  }

  // 프로필 정보 섹션 (요청자 <-> 수락자)
  Widget _buildProfileSection(SubstituteRequest request) {
    // 💡 이름에 따른 이니셜 및 색상 설정
    final String requesterInitial = request.requesterName.isNotEmpty ? request.requesterName[0] : '?';
    final String substituteInitial = request.substituteName?.isNotEmpty == true ? request.substituteName![0] : '?';

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 요청자 (From) - 주황색
          Expanded(
            child: _buildProfileCard(
              request.requesterName,
              '요청자',
              requesterInitial,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 8),
          // 화살표 아이콘
          const Icon(
            Icons.arrow_forward,
            color: AppColors.sectionTitleColor,
            size: 30,
          ),
          const SizedBox(width: 8),
          // 수락자 (To) - 초록색
          Expanded(
            child: _buildProfileCard(
              request.substituteName ?? '대타 미지정',
              '대타 지원자',
              substituteInitial,
              Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  // 개별 프로필 카드 (이니셜과 색상 기반으로 변경)
  Widget _buildProfileCard(String name, String role, String initial, Color baseColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: baseColor.withOpacity(0.15),
          child: Text(
            initial,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: baseColor),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.appTextPrimary),
        ),
        Text(
          role,
          style: const TextStyle(fontSize: 14, color: AppColors.sectionTitleColor),
        ),
      ],
    );
  }

  // 변경될 근무 상세 섹션
  Widget _buildScheduleDetails(String date, String time) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailItem(
            icon: Icons.calendar_month,
            label: date,
            primaryColor: AppColors.approvalPrimary,
          ),
          _buildDetailItem(
            icon: Icons.schedule,
            label: time,
            primaryColor: AppColors.approvalPrimary,
          ),
        ],
      ),
    );
  }

  // 상세 항목 위젯 (날짜/시간)
  Widget _buildDetailItem({required IconData icon, required String label, required Color primaryColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.appTextPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // 요청 사유 섹션
  Widget _buildReasonSection(String reason) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        reason,
        style: const TextStyle(
          fontSize: 15,
          color: AppColors.appTextPrimary,
          height: 1.5,
        ),
      ),
    );
  }

  // 하단 승인/거절 버튼 섹션
  Widget _buildActionButtons(BuildContext context, SubstituteRequest request) {
    // 💡 IN_REVIEW 상태일 때만 버튼 활성화
    final bool isHandled = request.status != 'IN_REVIEW';
    final String requesterName = request.requesterName;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          // 거절 버튼
          Expanded(
            child: ElevatedButton(
              // 💡 거절 로직 호출
              onPressed: isHandled ? null : () => _handleApproval(request.id, false, requesterName),
              style: ElevatedButton.styleFrom(
                foregroundColor: AppColors.rejectColor,
                backgroundColor: isHandled ? AppColors.borderGray : AppColors.borderGray,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                '거절하기',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isHandled ? AppColors.appTextSecondary : AppColors.rejectColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 승인 버튼
          Expanded(
            child: ElevatedButton(
              // 💡 승인 로직 호출
              onPressed: isHandled ? null : () => _handleApproval(request.id, true, requesterName),
              style: ElevatedButton.styleFrom(
                foregroundColor: AppColors.white,
                backgroundColor: isHandled ? AppColors.borderGray : AppColors.approvalPrimary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                '승인하기',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isHandled ? AppColors.appTextSecondary : AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
