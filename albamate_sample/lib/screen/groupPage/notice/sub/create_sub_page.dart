import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'dart:convert';

// 💡 요청하신 SubstituteRequest 모델 경로를 사용합니다.
import 'package:albamate_sample/screen/groupPage/notice/substitute_request.dart'; 

class CreateSubPage extends StatefulWidget {
  final String groupId;
  // 편집 기능은 구현되지 않았지만 타입 일관성을 위해 SubstituteRequest를 사용
  final SubstituteRequest? requestToEdit; 
  
  const CreateSubPage({required this.groupId, this.requestToEdit, super.key});

  @override
  _CreateSubPageState createState() => _CreateSubPageState();
}

class _CreateSubPageState extends State<CreateSubPage> {
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final TextEditingController _reasonController = TextEditingController();

  final DateFormat _dateFormat = DateFormat('yyyy년 M월 d일 (E)', 'ko_KR');
  
  // UI 상수
  static const Color primaryColor = Color(0xFF2b6cee);
  static const Color textLight = Color(0xFF0d121b);
  static const Color borderLight = Color(0xFFcfd7e7);
  static const Color placeholderLight = Color(0xFF4c669a);
  
  // 백엔드 API URL
  final String _backendApiUrl = 'https://backend-vgbf.onrender.com/api/substitute/requests';

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  // --- Date/Time Pickers ---

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2028),
      locale: const Locale('ko', 'KR'),
      helpText: '대타 요청 날짜 선택',
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? (_startTime ?? TimeOfDay.now()) : (_endTime ?? TimeOfDay.now()),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false), 
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  // --- Submission Logic with Backend Connection ---

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null || _startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('날짜와 시간을 모두 선택해주세요.')),
      );
      return;
    }

    // 시간 유효성 검사
    final start = DateTime(
      _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
      _startTime!.hour, _startTime!.minute
    );
    final end = DateTime(
      _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
      _endTime!.hour, _endTime!.minute
    );

    if (end.isBefore(start) || end.isAtSameMomentAs(start)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('종료 시간은 시작 시간보다 늦어야 합니다.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("로그인이 필요합니다.");
      }
      
      final idToken = await user.getIdToken();
      
      // 💡 [추가된 로직] Firestore에서 사용자 이름(name) 가져오기
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (!userDoc.exists || userDoc.data() == null || !userDoc.data()!.containsKey('name')) {
          throw Exception("Firestore에서 사용자 이름 정보를 찾을 수 없습니다.");
      }
      final requesterName = userDoc.data()!['name'] as String;
      // ----------------------------------------------------

      // 💡 [수정] postData에 'requester_name' 필드 추가
      final postData = {
        'group_id': widget.groupId,
        'shift_date': _selectedDate!.toIso8601String().split('T')[0], // YYYY-MM-DD
        'start_time': '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}:00', // HH:MM:SS
        'end_time': '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}:00',     // HH:MM:SS
        'reason': _reasonController.text, // 대타 요청 사유
        'requester_name': requesterName, // <-- 요청자 이름 추가
      };

      final response = await http.post(
        Uri.parse(_backendApiUrl), 
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(postData),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('대타 요청이 성공적으로 등록되었습니다.')),
        );
        // 요청 성공 시 이전 화면으로 돌아가면서 true 반환 (목록 새로고침 유도)
        if (mounted) Navigator.pop(context, true); 
      } else {
        // 서버에서 상세 오류 메시지를 가져옵니다.
        final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        final errorMessage = responseBody['message'] ?? '알 수 없는 서버 오류가 발생했습니다.';
        
        throw Exception('요청 등록 실패: $errorMessage (Code: ${response.statusCode})');
      }
    } catch (e) {
      debugPrint('요청 등록 중 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('요청 등록 중 오류가 발생했습니다: ${e.toString().contains('Exception:') ? e.toString().split('Exception:').last.trim() : '네트워크 또는 인증 오류'}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- UI Build Methods ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf6f6f8), 
      appBar: AppBar(
        backgroundColor: const Color(0xFFf6f6f8),
        leading: const BackButton(color: textLight),
        title: const Text(
          '대타 요청 작성',
          style: TextStyle(
            color: textLight,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: const [
          SizedBox(width: 48), 
        ],
      ),
      
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              
              _buildDateField(
                title: '날짜',
                placeholder: '날짜를 선택하세요',
                value: _selectedDate == null ? '' : _dateFormat.format(_selectedDate!),
                onTap: _selectDate,
                icon: Icons.calendar_today,
                validator: (value) => _selectedDate == null ? '날짜를 선택해주세요.' : null,
              ),

              const SizedBox(height: 12),
              
              _buildTimeFields(),
              
              const SizedBox(height: 12),

              _buildReasonField(),
            ],
          ),
        ),
      ),
      
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
        color: Colors.white, 
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submitRequest,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            minimumSize: const Size(double.infinity, 48), 
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: _isLoading 
              ? const SizedBox(
                  width: 24, 
                  height: 24, 
                  child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                )
              : const Text(
                  '요청 등록',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.015,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String title,
    required String placeholder,
    required String value,
    required VoidCallback onTap,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    const inputStyle = TextStyle(
      color: textLight,
      fontSize: 16,
      fontWeight: FontWeight.normal,
    );
    const placeholderStyle = TextStyle(
      color: placeholderLight,
      fontSize: 16,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              title,
              style: const TextStyle(
                color: textLight,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        GestureDetector(
          onTap: onTap,
          child: AbsorbPointer(
            child: TextFormField(
              controller: TextEditingController(text: value),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: placeholderStyle,
                filled: true,
                fillColor: Colors.white, 
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: borderLight, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: borderLight, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: primaryColor, width: 1),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Icon(icon, color: placeholderLight),
                ),
                suffixIconConstraints: const BoxConstraints(minHeight: 14, minWidth: 14),
                constraints: const BoxConstraints(maxHeight: 56), 
              ),
              style: inputStyle,
              validator: validator,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            '시간',
            style: const TextStyle(
              color: textLight,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                title: '',
                placeholder: '시작 시간', 
                value: _startTime?.format(context) ?? '',
                onTap: () => _selectTime(true),
                icon: Icons.schedule,
                validator: (value) => _startTime == null ? '시작 시간을 선택해주세요.' : null,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('~', style: TextStyle(color: textLight, fontSize: 18)),
            ),
            Expanded(
              child: _buildDateField(
                title: '',
                placeholder: '종료 시간', 
                value: _endTime?.format(context) ?? '',
                onTap: () => _selectTime(false),
                icon: Icons.schedule,
                validator: (value) => _endTime == null ? '종료 시간을 선택해주세요.' : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReasonField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            '사유',
            style: const TextStyle(
              color: textLight,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextFormField(
          controller: _reasonController,
          maxLines: 6, 
          decoration: InputDecoration(
            hintText: '대타를 구하는 이유를 자세히 적어주세요. (예: 급한 가족 행사)',
            hintStyle: const TextStyle(color: placeholderLight, fontSize: 16),
            filled: true,
            fillColor: Colors.white, 
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: borderLight, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: borderLight, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: primaryColor, width: 1),
            ),
            contentPadding: const EdgeInsets.all(15.0),
          ),
          style: const TextStyle(color: textLight, fontSize: 16),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '사유를 입력해주세요.';
            }
            return null;
          },
        ),
      ],
    );
  }
}