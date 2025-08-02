import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AutoCreateGuidePage extends StatefulWidget {
  const AutoCreateGuidePage({super.key});

  @override
  State<AutoCreateGuidePage> createState() => _AutoCreateGuidePageState();
}

class _AutoCreateGuidePageState extends State<AutoCreateGuidePage> {
  final TextEditingController _inputController = TextEditingController();
  String? _generatedText;
  String? _previousText;

  void _generateWithAI() async {
    final input = _inputController.text.trim();
    if (input.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse('https://backend-vgbf.onrender.com/notice/llm-generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'input': input}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _previousText = _generatedText;
          _generatedText = data['generated'] ?? '생성된 내용이 없습니다.';
        });
      } else if (response.statusCode == 503) {
        setState(() {
          _generatedText = '💡 Gemini 서버가 일시적으로 혼잡합니다. 잠시 후 다시 시도해주세요.';
        });
      } else {
        setState(() {
          _generatedText = '공지사항 생성 실패 (code: ${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _generatedText = '공지사항 생성 중 오류 발생: $e';
      });
    }
  }

  void _regenerate() {
    _generateWithAI(); // 같은 입력으로 다시 요청
  }

  void _revert() {
    setState(() {
      _generatedText = _previousText;
      _previousText = null;
    });
  }
   // 제목과 본문 넘기기
  void _applyToPreviousPage() {
  if (_generatedText == null) return;

  final result = _generatedText!;
  final title = RegExp(r'제목:\s*(.*)').firstMatch(result)?.group(1)?.trim();
  final content = RegExp(r'본문:\s*(.*)', dotAll: true).firstMatch(result)?.group(1)?.trim();

  if (title != null && content != null) {
    Navigator.pop(context, {
      'title': title,
      'content': content,
    });
  }
}


  List<String> _extractTagsFromInput() {
    return _inputController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
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
                      "AI가 문장을 다듬고 요약해드려요 ✨\n(쉼표로 항목을 구분해 주세요)",
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
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                            ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("AI 생성 결과", style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            // 제목 박스
                            Text("제목", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                            SizedBox(height: 4),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                RegExp(r'제목:\s*(.*)').firstMatch(_generatedText!)?.group(1) ?? '제목 없음',
                              ),
                            ),

                            SizedBox(height: 12),
                            // 본문
                            Text("본문", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                            SizedBox(height: 4),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                RegExp(r'본문:\s*(.*)', dotAll: true).firstMatch(_generatedText!)?.group(1)?.trim() ?? '본문 없음',
                                style: TextStyle(fontSize: 16, height: 1.6),
                              ),
                            ),


                            SizedBox(height: 12),
                            // 태그 표시
                            Wrap(
                              spacing: 6,
                              children: _extractTagsFromInput()
                                  .map((tag) => Chip(label: Text('#$tag')))
                                  .toList(),
                            ),
                            SizedBox(height: 12),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: _previousText != null ? _revert : null,
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
