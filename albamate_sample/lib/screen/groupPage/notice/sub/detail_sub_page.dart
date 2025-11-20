//dart:Substitute Request Detail Screen (Final Corrected Code - Fix Claimed State):lib/screen/groupPage/notice/detail_sub_page.dart
import 'package:flutter/material.dart';
import 'package:albamate_sample/screen/groupPage/notice/substitute_request.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

// ======================================================================
// 1. App Colors & Constants
// ======================================================================

class AppColors {
  static const Color appPrimary = Color(0xFF007AFF); // primary
  static const Color appBackground = Color(0xFFF2F2F7);
  static const Color appTextPrimary = Color(0xFF1C1C1E);
  static const Color appTextSecondary = Color(0xFF8E8E93);
  static const Color borderGray = Color(0xFFE5E5EA);
  static const Color white = Colors.white;
}

// ======================================================================
// 2. Helper Class for UI (SubstituteRequest의 데이터를 UI 친화적으로 변환)
// ======================================================================

class SubstituteRequestDisplay {
  final SubstituteRequest request;
  final DateTime shiftStart;
  final DateTime shiftEnd;
  final bool isAcceptable;

  SubstituteRequestDisplay(this.request)
      : shiftStart = _parseDateTime(request.shiftDate, request.startTime),
        shiftEnd = _parseDateTime(request.shiftDate, request.endTime),
        // PENDING 또는 IN_REVIEW 상태일 때만 수락 가능하다고 간주
        isAcceptable = request.status == 'PENDING' || request.status == 'IN_REVIEW';

  static DateTime _parseDateTime(String date, String time) {
    try {
      return DateTime.parse('$date $time');
    } catch (e) {
      return DateTime.now();
    }
  }
}

// ======================================================================
// 3. DetailSubPage (메인 위젯)
// ======================================================================

class DetailSubPage extends StatefulWidget {
  final String requestId;
  final String userRole;

  const DetailSubPage({required this.requestId, required this.userRole, super.key});

  @override
  State<DetailSubPage> createState() => _DetailSubPageState();
}

class _DetailSubPageState extends State<DetailSubPage> {
  late Future<SubstituteRequest> _requestDetailFuture;

  final String _backendBaseUrl = 'https://backend-vgbf.onrender.com/api/substitute/requests';
  String? _currentUserName;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _requestDetailFuture = _fetchShiftRequestDetail(widget.requestId);
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _currentUserId = user.uid;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists && mounted) {
        setState(() {
          _currentUserName = userDoc.data()?['name'];
        });
      }
    }
  }

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

  void _acceptShift(String requestId) async {
    if (_currentUserName == null || _currentUserId == null) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('사용자 정보를 가져오는 중입니다. 잠시 후 다시 시도해주세요.'), duration: Duration(seconds: 2)),
       );
      return;
    }

    if (mounted) setState(() { _requestDetailFuture = Future.error('Loading...'); });

    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();

      final putData = {
        'substitute_id': _currentUserId,
        'substitute_name': _currentUserName,
      };

      final response = await http.put(
        Uri.parse('$_backendBaseUrl/$requestId/accept'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(putData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_currentUserName}님의 대타 수락 요청을 보냈습니다!'), duration: const Duration(seconds: 2)),
        );
        _requestDetailFuture = _fetchShiftRequestDetail(widget.requestId);
      } else {
        final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        final errorMessage = responseBody['message'] ?? '수락 중 알 수 없는 서버 오류가 발생했습니다.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('수락 요청 중 오류 발생: ${e.toString().split(':').last.trim()}'), duration: const Duration(seconds: 3)),
      );
      _requestDetailFuture = _fetchShiftRequestDetail(widget.requestId);
    } finally {
       if (mounted) setState(() {});
    }
  }


  @override
  Widget build(BuildContext context) {
    final bool isBoss = widget.userRole == '사장님';

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        backgroundColor: AppColors.appBackground,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '대타 요청 상세',
          style: TextStyle(
            color: AppColors.appTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.appTextPrimary, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: const [SizedBox(width: 48)],
      ),

      body: FutureBuilder<SubstituteRequest>(
        future: _requestDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.appPrimary));
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('데이터를 불러오지 못했습니다: ${snapshot.error}', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.appTextSecondary)),
              ),
            );
          } else if (snapshot.hasData) {
            final rawRequest = snapshot.data!;
            final displayRequest = SubstituteRequestDisplay(rawRequest);

            return _buildContent(context, displayRequest);
          } else {
            return const Center(child: Text('요청 정보를 찾을 수 없습니다.', style: TextStyle(color: AppColors.appTextSecondary)));
          }
        },
      ),

      bottomNavigationBar: isBoss ? null : _buildBottomCtaDynamic(),
    );
  }

  // --- UI 빌더 함수 ---

  Widget _buildContent(BuildContext context, SubstituteRequestDisplay request) {
    final double bottomPadding = widget.userRole == '사장님' ? 16 : 120;

    return SingleChildScrollView(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildRequesterInfoCard(request),
              const SizedBox(height: 16),
              _buildShiftDetailsCard(request),
              const SizedBox(height: 16),
              _buildReasonCard(request),
            ],
          ),
        ),
      );
  }

  Widget _buildRequesterInfoCard(SubstituteRequestDisplay request) {
    String statusText;
    Color statusBgColor;
    Color statusTextColor;

    final status = request.request.status;
    final substituteName = request.request.substituteName;

    // 💡 [수정]: 상태별 표시 텍스트와 색상을 명확하게 분리
    if (status == 'APPROVED') {
      // 최종 승인 완료
      statusText = substituteName != null ? '$substituteName 수락 완료' : '승인 완료';
      statusBgColor = Colors.green[100]!;
      statusTextColor = Colors.green[700]!;
    } else if (status == 'IN_REVIEW') {
      // 대타가 수락했지만 사장님 승인 대기 중인 상태
      statusText = substituteName != null ? '$substituteName 승인 대기' : '승인 대기';
      statusBgColor = AppColors.appPrimary.withOpacity(0.15);
      statusTextColor = AppColors.appPrimary;
    } else if (status == 'PENDING') {
      // 아직 아무도 수락하지 않은 상태
      statusText = '대타 찾는 중';
      statusBgColor = Colors.grey[100]!;
      statusTextColor = AppColors.appTextSecondary;
    } else if (status == 'REJECTED') {
      // 거절됨
      statusText = '거절됨';
      statusBgColor = Colors.red[100]!;
      statusTextColor = Colors.red[600]!;
    }
    else {
      // 기타 마감/취소 등
      statusText = '마감/취소';
      statusBgColor = AppColors.appTextSecondary.withOpacity(0.1);
      statusTextColor = AppColors.appTextSecondary;
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.appPrimary.withOpacity(0.1),
            child: const Icon(
              Icons.person,
              color: AppColors.appPrimary,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(request.request.requesterName, style: const TextStyle(color: AppColors.appTextPrimary, fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                const Text('요청자 (알바)', style: TextStyle(color: AppColors.appTextSecondary, fontSize: 14)),
              ],
            ),
          ),
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: statusBgColor, borderRadius: BorderRadius.circular(8.0)),
            alignment: Alignment.center,
            child: Text(
              statusText,
              style: TextStyle(color: statusTextColor, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftDetailsCard(SubstituteRequestDisplay request) {
    final DateFormat dateFormatter = DateFormat('yyyy년 M월 d일 (E)', 'ko');
    final String dateDisplay = dateFormatter.format(request.shiftStart);

    final int durationInMinutes = request.shiftEnd.difference(request.shiftStart).inMinutes;
    final double durationInHours = durationInMinutes / 60.0;

    final String timeDisplay = '${DateFormat('HH:mm').format(request.shiftStart)} ~ ${DateFormat('HH:mm').format(request.shiftEnd)}';
    final String durationDisplay = '${durationInHours.toStringAsFixed(durationInHours.truncateToDouble() == durationInHours ? 0 : 1)}시간';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _buildDetailRow('근무 날짜', dateDisplay, needsDivider: false),
          _buildDetailRow('근무 시간', '$timeDisplay ($durationDisplay)', needsDivider: true),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {required bool needsDivider}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        border: needsDivider ? const Border(top: BorderSide(color: AppColors.borderGray, width: 1)) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.appTextSecondary, fontSize: 14, fontWeight: FontWeight.normal)),
          Text(value, style: const TextStyle(color: AppColors.appTextPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildReasonCard(SubstituteRequestDisplay request) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('요청 사유', style: const TextStyle(color: AppColors.appTextPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(request.request.reason, style: const TextStyle(color: AppColors.appTextPrimary, fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16.0),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
      ],
    );
  }

  // 4. CTA 버튼 로직 (비활성화 로직 포함)
  Widget _buildBottomCtaDynamic() {
    return FutureBuilder<SubstituteRequest>(
      future: _requestDetailFuture,
      builder: (context, snapshot) {
        bool isLoading = snapshot.connectionState == ConnectionState.waiting;
        final bool isDataAvailable = snapshot.hasData;

        String buttonText = '대타 수락하기';
        String? message;
        VoidCallback? onPressed;
        bool isButtonEnabled = false;

        if (isLoading || _currentUserName == null) {
          message = '정보를 불러오는 중...';
        } else if (!isDataAvailable || snapshot.hasError) {
          message = '요청 정보를 가져올 수 없습니다.';
        } else {
          final rawRequest = snapshot.data!;
          final displayRequest = SubstituteRequestDisplay(rawRequest);

          final bool isOwner = rawRequest.requesterName == _currentUserName;
          final bool isClaimed = rawRequest.substituteName != null;

          if (isOwner) {
            // Case 1: 요청자 본인 (비활성화)
            message = '본인이 요청한 근무는 수락할 수 없습니다.';
          } else if (rawRequest.status == 'APPROVED' || rawRequest.status == 'REJECTED') {
            // Case 2: 상태가 APPROVED/REJECTED 등으로 최종 확정된 경우 (비활성화)
            message = rawRequest.status == 'APPROVED' ?
                      '${rawRequest.substituteName}님이 최종 수락했습니다.' :
                      '이미 거절되어 마감된 요청입니다.';
          } else if (rawRequest.status == 'IN_REVIEW') {
             // 💡 [수정]: Case 3: IN_REVIEW 상태일 때 (누군가 수락한 상태)
            message = '${rawRequest.substituteName}님이 이 근무를 수락 대기 중입니다. (사장님 승인 필요)';
          } else if (rawRequest.status == 'PENDING' && !isClaimed) {
            // Case 4: 상태가 PENDING 이고 아직 아무도 수락하지 않은 경우 (활성화)
            message = null;
            onPressed = () => _acceptShift(rawRequest.id);
            isButtonEnabled = true;
          } else {
            // 기타 상태 (예: PENDING인데 substituteName이 잘못 남아있는 경우 등)
             message = '현재 상태에서는 대타 수락이 불가능합니다.';
          }
        }

        final finalOnPressed = isButtonEnabled ? onPressed : null;

        return _buildCtaButton(
          context,
          text: buttonText,
          onPressed: finalOnPressed,
          message: message,
        );
      },
    );
  }

  Widget _buildCtaButton(BuildContext context, {required String text, VoidCallback? onPressed, String? message}) {
    final bool isEnabled = onPressed != null;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.95),
        border: const Border(top: BorderSide(color: AppColors.borderGray, width: 0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (message != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.appTextSecondary, fontSize: 12)),
            ),
          ElevatedButton(
            onPressed: onPressed, // null이면 클릭 불가
            style: ElevatedButton.styleFrom(
              // 비활성화 시 색상 변경
              backgroundColor: isEnabled ? AppColors.appPrimary : AppColors.borderGray,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(
              text,
              style: TextStyle(
                // 비활성화 시 텍스트 색상 변경
                color: isEnabled ? AppColors.white : AppColors.appTextSecondary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}