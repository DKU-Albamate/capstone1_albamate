import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
// 💡 SubstituteRequest 모델 파일 경로 확인
import 'package:albamate_sample/screen/groupPage/notice/substitute_request.dart';
// 💡 상세 페이지 import
import 'approval_request_detail_page.dart';

// ======================================================================
// 유틸리티 및 상수
// ======================================================================

class AppColors {
  static const Color appBackground = Color(0xFFF6F6F8);
  static const Color appTextPrimary = Color(0xFF1C1C1E);
  static const Color approvalPrimary = Color(0xFF006FFD);
  static const Color white = Colors.white;
  static const Color dividerColor = Color(0xFFF0F0F0);
  static const Color appTextSecondary = Color(0xFF8E8E93);
  static const Color rejectColor = Color(0xFFDC3545); // 거절 버튼 색상
}

// 승인 대기 상태에 맞춘 색상 및 번역 유틸리티 함수
Color _getStatusColor(String status) {
  switch (status) {
    case 'IN_REVIEW': return AppColors.approvalPrimary;
    default: return Colors.grey[700]!;
  }
}

Color _getStatusBackgroundColor(String status) {
  switch (status) {
    case 'IN_REVIEW': return AppColors.approvalPrimary.withOpacity(0.15);
    default: return Colors.grey[100]!;
  }
}

String _translateStatus(String status) {
  switch (status) {
    case 'IN_REVIEW': return '승인 대기';
    default: return '처리 완료';
  }
}

// ======================================================================

class ApprovalRequestsPage extends StatefulWidget {
  final String groupId;

  const ApprovalRequestsPage({required this.groupId, super.key});

  @override
  State<ApprovalRequestsPage> createState() => _ApprovalRequestsPageState();
}

class _ApprovalRequestsPageState extends State<ApprovalRequestsPage> {
  Future<List<SubstituteRequest>>? _requestsFuture;
  final String _backendUrl = 'https://backend-vgbf.onrender.com/api/substitute/requests';

  // 💡 버튼 중복 클릭 방지 및 로딩 상태 추적을 위한 맵 (requestId: isProcessing)
  final Map<String, bool> _processingRequests = {};

  @override
  void initState() {
    super.initState();
    _requestsFuture = _fetchApprovalRequests();
  }

  // 승인 대기 중인 요청 목록을 불러오는 함수 (API 통신)
  Future<List<SubstituteRequest>> _fetchApprovalRequests() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();

    // group_id와 status=IN_REVIEW 필터링 쿼리
    final uri = Uri.parse('$_backendUrl?group_id=${widget.groupId}&status=IN_REVIEW');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        final List data = responseBody['data'] ?? [];

        return data.map((item) => SubstituteRequest.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception('요청 로딩 실패: 상태 코드 ${response.statusCode}, 메시지: ${errorBody['message'] ?? '알 수 없는 서버 오류'}');
      }
    } catch (e) {
      debugPrint('API 호출 오류: $e');
      throw Exception('대타 요청 목록을 불러오는 중 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.');
    }
  }

  // 요청 목록을 새로고침하는 함수
  Future<void> _refreshRequests() async {
    if (mounted) {
      setState(() {
        _requestsFuture = _fetchApprovalRequests();
        _processingRequests.clear(); // 처리 상태 초기화
      });
    }
  }

  // 💡 [통합 로직] 승인/거절 처리를 위한 헬퍼 함수 (상세 페이지와 동일한 API 사용)
  Future<void> _manageRequest(String requestId, String finalStatus, String actionName) async {
    if (_processingRequests[requestId] == true) return;

    if (mounted) setState(() { _processingRequests[requestId] = true; });

    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();

      // 💡 1. URL 경로 변경: /:request_id/manage 로 통일
      final Uri uri = Uri.parse('$_backendUrl/$requestId/manage');

      // 💡 2. 요청 바디 변경: final_status 필드만 사용
      final putData = {
        'final_status': finalStatus, // 'APPROVED' 또는 'REJECTED'
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
      // 서버 응답 처리 로직
      // =========================================================
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ 대타 요청이 성공적으로 $actionName 처리되었습니다!'), duration: const Duration(seconds: 2)),
        );
        // 💡 [목록 핵심 수정]: 처리 후 목록을 새로고침하여 제거
        _refreshRequests();
      } else {
        String errorMessage;
        String responseBodyString = utf8.decode(response.bodyBytes);

        try {
          final responseBody = jsonDecode(responseBodyString);
          errorMessage = responseBody['message'] ?? '$actionName 처리 중 알 수 없는 서버 오류가 발생했습니다.';
        } catch (e) {
          errorMessage = '서버 응답 오류 (상태: ${response.statusCode}). 서버 로그를 확인해 주세요.';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❗️ $actionName 실패: ${e.toString().split(':').last.trim()}'), duration: const Duration(seconds: 3)),
      );
    } finally {
      if (mounted) setState(() { _processingRequests.remove(requestId); });
    }
  }

  // 💡 [수정] 대타 요청 승인 처리 함수 (헬퍼 연결)
  Future<void> _approveRequest(String requestId) async {
    await _manageRequest(requestId, 'APPROVED', '승인');
  }

  // 💡 [수정] 대타 요청 거절 처리 함수 (헬퍼 연결)
  Future<void> _rejectRequest(String requestId) async {
    await _manageRequest(requestId, 'REJECTED', '거절');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        title: const Text('대타 요청 승인', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.appTextPrimary)),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<SubstituteRequest>>(
        future: _requestsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.approvalPrimary));
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  '데이터 로딩 오류: ${snapshot.error.toString()}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red[700]),
                ),
              ),
            );
          } else if (snapshot.hasData) {
            final requests = snapshot.data!;
            final bool isEmpty = requests.isEmpty;

            if (isEmpty) {
              return _buildEmptyState();
            }

            // 💡 아래로 당겨 새로고침(Pull-to-refresh) 기능
            return RefreshIndicator(
              onRefresh: _refreshRequests,
              color: AppColors.approvalPrimary,
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return _buildRequestCard(context, request);
                },
              ),
            );
          } else {
             return _buildEmptyState();
          }
        },
      ),
    );
  }

  // 요청 카드 위젯
  Widget _buildRequestCard(BuildContext context, SubstituteRequest request) {
    final String fromName = request.requesterName;
    final String toName = request.substituteName ?? '대타 미지정';

    final DateTime shiftStart = DateTime.parse('${request.shiftDate} ${request.startTime}');
    final DateTime shiftEnd = DateTime.parse('${request.shiftDate} ${request.endTime}');

    final String dateDisplay = DateFormat('yyyy년 M월 d일 (E)', 'ko').format(shiftStart);
    final String timeDisplay = '${DateFormat('HH:mm').format(shiftStart)} ~ ${DateFormat('HH:mm').format(shiftEnd)}';

    // 현재 요청이 처리 중인지 확인
    final bool isProcessing = _processingRequests[request.id] == true;


    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. 요청 정보 섹션 (클릭 영역)
          GestureDetector(
            onTap: isProcessing ? null : () {
              // 💡 상세 페이지로 이동하며 실제 requestId를 전달합니다.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ApprovalRequestDetailPage(requestId: request.id),
                ),
              ).then((needsRefresh) {
                // 상세 페이지에서 승인/거절 처리 후 true가 반환되면 목록을 새로고침합니다.
                if (needsRefresh == true) {
                  _refreshRequests();
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // 요청자 프로필 (주황색)
                          _buildProfileWithLabel(fromName, fromName.isNotEmpty ? fromName[0] : '?', Colors.orange),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_right_alt, color: Colors.grey, size: 24),
                          const SizedBox(width: 8),
                          // 대타 지원자 프로필 (녹색)
                          _buildProfileWithLabel(toName, toName.isNotEmpty ? toName[0] : '?', Colors.green),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusBackgroundColor(request.status),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _translateStatus(request.status),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(request.status),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 24, thickness: 1, color: AppColors.dividerColor),

                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateDisplay,
                          style: const TextStyle(color: AppColors.appTextSecondary, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          timeDisplay,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.appTextPrimary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. 💡 액션 버튼 섹션
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                // 거절하기 버튼
                Expanded(
                  child: ElevatedButton(
                    onPressed: isProcessing ? null : () => _rejectRequest(request.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.rejectColor,
                      foregroundColor: AppColors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: isProcessing
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 3))
                        : const Text('거절하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                // 승인하기 버튼
                Expanded(
                  child: ElevatedButton(
                    onPressed: isProcessing ? null : () => _approveRequest(request.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.approvalPrimary,
                      foregroundColor: AppColors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: isProcessing
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 3))
                        : const Text('승인하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 프로필과 이름 위젯 (이니셜 사용)
  Widget _buildProfileWithLabel(String name, String initial, Color baseColor) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: baseColor.withOpacity(0.15),
          child: Text(
            initial,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: baseColor),
          ),
        ),
        const SizedBox(height: 4),
        Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.appTextPrimary)),
      ],
    );
  }

  // 요청이 없을 때 표시되는 위젯
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.task_alt, size: 40, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text(
              '모든 요청을 처리했습니다',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.appTextPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              '승인 대기 중인 대타 요청이 없습니다.',
              style: TextStyle(color: AppColors.appTextSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}