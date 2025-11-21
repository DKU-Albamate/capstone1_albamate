import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:albamate_sample/screen/groupPage/notice/substitute_request.dart';
import 'detail_sub_page.dart';
import 'create_sub_page.dart';
// 💡 [경로 수정]: 이 import 경로를 'approval_requests_page.dart' 파일의 실제 위치에 맞게 수정하세요!
import 'approval_requests_page.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

// ======================================================================
// 💡 백엔드 상태 문자열 기반 색상 및 번역 유틸리티 함수
Color _getStatusColor(String status) {
  switch (status) {
    case 'APPROVED': return Colors.green[700]!;
    case 'IN_REVIEW': return const Color(0xFF006FFD);
    case 'PENDING': return Colors.grey[600]!;
    case 'REJECTED': return Colors.red[600]!;
    default: return Colors.grey;
  }
}

Color _getStatusBackgroundColor(String status) {
  switch (status) {
    case 'APPROVED': return Colors.green[100]!;
    case 'IN_REVIEW': return const Color(0xFF006FFD).withOpacity(0.15);
    case 'PENDING': return Colors.grey[100]!;
    case 'REJECTED': return Colors.red[100]!;
    default: return Colors.grey[100]!;
  }
}

String _translateStatus(String status) {
  switch (status) {
    case 'APPROVED': return '승인 완료';
    case 'IN_REVIEW': return '승인 대기';
    case 'PENDING': return '대타 구하는 중';
    case 'REJECTED': return '거절됨';
    default: return '알 수 없음';
  }
}

// ======================================================================

class ScreenSubPage extends StatefulWidget {
  final String groupId;

  const ScreenSubPage({required this.groupId, super.key});

  @override
  _ScreenSubPageState createState() => _ScreenSubPageState();
}

class _ScreenSubPageState extends State<ScreenSubPage> {
  List<SubstituteRequest> requests = [];
  String? userRole;
  String? userUid;
  String? userName;
  bool _isLoading = false;
  final String _backendUrl = 'https://backend-vgbf.onrender.com/api/substitute/requests';

  @override
  void initState() {
    super.initState();
    userUid = FirebaseAuth.instance.currentUser?.uid;
    _fetchUserRoleAndRequests();
  }

  // 💡 [핵심 수정 함수]
  Future<void> _fetchUserRoleAndRequests() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      String currentRole = '알바생'; // 💡 기본값을 '알바생'으로 설정
      String? fetchedUserName;

      if (user != null) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
            String fetchedRole = userDoc.data()?['role'] ?? '알바생';
            if (fetchedRole == '사장님') {
                currentRole = '사장님';
            } else {
                // "사장님"이 아닌 모든 값은 안전하게 '알바생'으로 처리
                currentRole = '알바생';
            }
            fetchedUserName = userDoc.data()?['name'];
        }
      }

      // 상태 업데이트
      if(mounted) {
        setState(() {
          userRole = currentRole;
          userName = fetchedUserName;
        });
      }

      // 💡 [핵심 디버깅]: 현재 역할 확인
      debugPrint('================================================');
      debugPrint('현재 사용자 역할: $currentRole');

      // 💡 [핵심 필터링]: 알바생 역할일 때만 PENDING 상태 필터를 추가
      String requestUrl = '$_backendUrl?group_id=${widget.groupId}';
      if (currentRole != '사장님') {
        // 알바생인 경우, PENDING 상태의 게시글만 요청
        requestUrl += '&status=PENDING';
      }

      // 💡 [핵심 디버깅]: 최종 API 요청 URL 확인
      debugPrint('최종 API Request URL: $requestUrl');
      debugPrint('================================================');

      final token = await user?.getIdToken();

      final response = await http.get(
        Uri.parse(requestUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 && mounted) {
        final Map<String, dynamic> responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        final data = responseBody['data'] as List;

        final List<SubstituteRequest> fetchedRequests = [];
        for (var item in data) {
          try {
            final request = SubstituteRequest.fromJson(item);
            fetchedRequests.add(request);
          } catch (e) {
            debugPrint('경고: JSON 파싱 오류 또는 ID 누락으로 항목 제외: $e');
          }
        }

        setState(() {
          requests = fetchedRequests;
          _isLoading = false;
        });
      } else {
        debugPrint('API 호출 실패: ${response.statusCode}, ${response.body}');
        if (mounted) {
           setState(() {
             requests = [];
             _isLoading = false;
           });
        }
      }
    } catch (e) {
      debugPrint('데이터 불러오기 오류: $e');
      if (mounted) {
        setState(() {
          requests = [];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteRequest(String requestId, String requesterName) async {
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();

      final response = await http.delete(
        Uri.parse('$_backendUrl/$requestId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'requester_name': requesterName}),
      );

      if (response.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('대타 요청이 성공적으로 삭제되었습니다.')),
        );
        _fetchUserRoleAndRequests();
      } else {
        final message = jsonDecode(utf8.decode(response.bodyBytes))['message'] ?? '삭제에 실패했습니다.';
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 실패: $message')),
        );
      }
    } catch (e) {
      debugPrint('삭제 중 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('삭제 중 네트워크 오류 발생')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isBoss = userRole == '사장님';

    final body = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : requests.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upcoming, size: 60, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      isBoss ? '아직 처리할 요청이 없어요.' : '현재 대타를 구하는 요청이 없어요.',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isBoss ? '모든 요청이 처리되었거나 새 요청을 기다리고 있습니다.' : '필요한 경우 새 대타 요청을 등록해보세요!',
                      style: const TextStyle(color: Colors.grey)
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _fetchUserRoleAndRequests,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];

                    final bool isAuthorByName = userName != null && userName == request.requesterName;
                    final bool canDelete = isBoss || (isAuthorByName && request.status == 'PENDING');

                    final String formattedShiftTime =
                        request.shiftDate.isNotEmpty && request.startTime.isNotEmpty && request.endTime.isNotEmpty
                        ? DateFormat('MM월 dd일 (E) HH:mm').format(DateTime.parse('${request.shiftDate} ${request.startTime}')) +
                          ' ~ ' +
                          DateFormat('HH:mm').format(DateTime.parse('${request.shiftDate} ${request.endTime}'))
                        : '시간 정보 없음';

                    final String authorDisplay = isAuthorByName
                        ? '나 (${request.requesterName})'
                        : request.requesterName;

                    final String firstChar = authorDisplay.isNotEmpty ? authorDisplay[0] : '';
                    final Color avatarColor = Colors.primaries[firstChar.hashCode % Colors.primaries.length];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DetailSubPage(
                                  requestId: request.id,
                                  userRole: userRole!,
                                ),
                          ),
                        ).then((_) {
                          if (mounted) _fetchUserRoleAndRequests();
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              spreadRadius: 0,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
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
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: avatarColor.withOpacity(0.15),
                                        child: Text(
                                          firstChar,
                                          style: TextStyle(
                                            color: avatarColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        authorDisplay,
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
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
                                      if (canDelete)
                                        PopupMenuButton<String>(
                                          onSelected: (value) async {
                                            if (value == 'delete') {
                                              if (userName != null) {
                                                await _deleteRequest(request.id, userName!);
                                              }
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(value: 'delete', child: Text('삭제하기')),
                                          ],
                                          icon: const Icon(Icons.more_vert),
                                          padding: EdgeInsets.zero,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  request.reason,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[800]),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Row(
                                  children: [
                                    Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                                    const SizedBox(width: 4),
                                    Text(
                                      formattedShiftTime,
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );

    final fab = FloatingActionButton.extended(
      backgroundColor: isBoss ? const Color(0xFF10B981) : const Color(0xFF006FFD),
      onPressed: () async {
        if (isBoss) {
          // 사장님: 승인 목록 페이지로 이동
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ApprovalRequestsPage(groupId: widget.groupId)),
          ).then((_) {
            if (mounted) _fetchUserRoleAndRequests();
          });
        } else {
          // 알바생: 대타 요청 생성 페이지로 이동
          final created = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateSubPage(groupId: widget.groupId)),
          );
          if (created == true && mounted) _fetchUserRoleAndRequests();
        }
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      label: Text(
        isBoss ? '대타 요청 승인' : '대타 요청하기',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
      ),
      icon: Icon(isBoss ? Icons.check_circle_outline : Icons.add, color: Colors.white),
    );

    return Scaffold(
      body: body,
      floatingActionButton: fab,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}