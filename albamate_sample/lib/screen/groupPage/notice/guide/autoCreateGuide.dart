import 'package:flutter/material.dart';
import 'dart:convert'; // 나중에 API 통신 시 사용
import 'package:http/http.dart' as http; // 나중에 API 통신 시 사용

class AutoCreateGuidePage extends StatefulWidget {
  const AutoCreateGuidePage({super.key});

  @override
  State<AutoCreateGuidePage> createState() => _AutoCreateGuidePageState();
}

class _AutoCreateGuidePageState extends State<AutoCreateGuidePage> {
  final TextEditingController _inputController = TextEditingController();
  String? _generatedText;

  // TODO: 삭제 예정 - 더미 요약 결과
  final String _dummySummary = '오늘부터 매장 운영시간이 변경됩니다. 꼭 확인해주세요!';
  // TODO: 삭제 예정 - 더미 키워드
  final List<String> _dummyTags = ['운영 시간', '중요', '긴급'];

  void _generateWithAI() async {
    final input = _inputController.text.trim();
    if (input.isEmpty) return;

    // TODO: 삭제 예정 - 더미 요약 적용
    setState(() {
      _generatedText = _dummySummary;
    });

    // TODO: 나중에 실제 Gemini, GPT, Clova 등 AI API 요청으로 대체
  }

  void _regenerate() {
    // TODO: 삭제 예정 - 재생성 더미 값
    setState(() {
      _generatedText = '내일 점심시간에 전원 회의가 예정되어 있습니다. 사전 준비 바랍니다.';
    });
  }

  void _revert() {
    setState(() {
      _generatedText = null;
    });
  }

  void _applyToPreviousPage() {
    if (_generatedText != null) {
      Navigator.pop(context, _generatedText); // 결과 전달
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('공지사항 자동 생성'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "AI가 문장을 다듬고 요약해드려요 ✨",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 12),

                    // 사용자 입력
                    SizedBox(
                      height: 140,
                      child: TextField(
                        controller: _inputController,
                        expands: true,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: '공지 내용을 입력해 주세요',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),

                    // 에디터 버튼들 (시각적 도움만)
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.format_bold),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.format_align_left),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.text_fields),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: _generateWithAI,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF006FFD),
                          foregroundColor: Colors.white,
                          minimumSize: Size(140, 36),
                          padding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: Text("공지사항 자동 생성"),
                      ),
                    ),
                    SizedBox(height: 16),

                    // 생성된 결과 표시
                    if (_generatedText != null)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "AI 생성 결과",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text(_generatedText!),
                            SizedBox(height: 8),

                            // TODO: 삭제 예정 - 더미 키워드 태그
                            Wrap(
                              spacing: 6,
                              children:
                                  _dummyTags
                                      .map((tag) => Chip(label: Text('#$tag')))
                                      .toList(),
                            ),
                            SizedBox(height: 12),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: _revert,
                                  child: Text("되돌리기"),
                                ),
                                TextButton(
                                  onPressed: _regenerate,
                                  child: Text("재생성"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // 하단 적용 버튼
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _generatedText != null ? _applyToPreviousPage : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF006FFD),
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 48),
                ),
                child: Text("적용"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
