import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'worker_homecalendar.dart';
import 'worker_imageProcessing.dart'; // Schedule 클래스 정의

class WorkerImageParseViewPage extends StatefulWidget {
  final File imageFile;
  final List<Schedule> schedules;

  const WorkerImageParseViewPage({
    super.key,
    required this.imageFile,
    required this.schedules,
  });

  @override
  State<WorkerImageParseViewPage> createState() => _WorkerImageParseViewPageState();
}

class _WorkerImageParseViewPageState extends State<WorkerImageParseViewPage> {
  late List<Schedule> _schedules;
  late List<bool> _editModes;

  final _dateFmt = DateFormat('M월 d일 (E)', 'ko');

  @override
  void initState() {
    super.initState();
    _schedules = List.from(widget.schedules);
    _editModes = List.filled(_schedules.length, false, growable: true);
  }

  String _fmt(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _selectDate(int index) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _schedules[index].date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _schedules[index].date = picked;
      });
    }
  }

  Future<void> _selectTime(int index, bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _schedules[index].start : _schedules[index].end,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _schedules[index].start = picked;
        } else {
          _schedules[index].end = picked;
        }
      });
    }
  }

  Future<void> _saveToServer() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("로그인이 필요합니다")),
      );
      return;
    }

    final body = {
      "user_uid": user.uid,
      "use_gemini": "true",
      "schedules": _schedules.map((e) => {
        "title": e.title,
        "date": DateFormat('yyyy-MM-dd').format(e.date),
        "start": _fmt(e.start),
        "end": _fmt(e.end),
      }).toList()
    };

    try {
      final response = await http.post(
        Uri.parse('https://backend-vgbf.onrender.com/ocr/save'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const WorkerHomecalendar()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류 발생: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: const Text('스케줄 추출 결과')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF006FFD).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF006FFD).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.psychology, color: Color(0xFF006FFD)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  ' Gemini 2.5 Flash Lite AI 분석',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF006FFD),
                                  ),
                                ),
                                Text(
                                  '${_schedules.length}개의 일정이 추출되었습니다',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: h * 0.35,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade100,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: InteractiveViewer(
                          child: Image.file(widget.imageFile, fit: BoxFit.contain),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    /// ✅ 여기가 핵심 부분! '추출된 일정' + ⊕ 버튼 Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '추출된 일정',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          color: const Color(0xFF006FFD),
                          tooltip: '일정 추가',
                          onPressed: () {
                            setState(() {
                              _schedules.add(Schedule.empty());
                              _editModes.add(true);
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    _schedules.isEmpty
                        ? const Center(
                            child: Column(
                              children: [
                                Icon(Icons.info_outline, size: 48, color: Colors.grey),
                                SizedBox(height: 16),
                                Text('추출된 일정이 없습니다.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                                SizedBox(height: 8),
                                Text('이미지를 다시 확인해주세요.', style: TextStyle(color: Colors.grey, fontSize: 14)),
                              ],
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _schedules.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, i) {
                              final s = _schedules[i];

                              return _editModes[i]
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        TextField(
                                          decoration: const InputDecoration(labelText: '제목'),
                                          controller: TextEditingController(text: s.title),
                                          onChanged: (val) => s.title = val,
                                        ),
                                        Row(
                                          children: [
                                            TextButton(
                                              onPressed: () => _selectDate(i),
                                              child: Text(_dateFmt.format(s.date)),
                                            ),
                                            const SizedBox(width: 8),
                                            TextButton(
                                              onPressed: () => _selectTime(i, true),
                                              child: Text('시작: ${_fmt(s.start)}'),
                                            ),
                                            TextButton(
                                              onPressed: () => _selectTime(i, false),
                                              child: Text('종료: ${_fmt(s.end)}'),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            TextButton.icon(
                                              onPressed: () {
                                                setState(() {
                                                  _editModes[i] = false;
                                                });
                                              },
                                              icon: const Icon(Icons.check),
                                              label: const Text('저장'),
                                            ),
                                          ],
                                        )
                                      ],
                                    )
                                  : Slidable(
                                      key: ValueKey('schedule_$i'),
                                      endActionPane: ActionPane(
                                        motion: const ScrollMotion(),
                                        extentRatio: 0.4,
                                        children: [
                                          SlidableAction(
                                            onPressed: (_) {
                                              setState(() {
                                                _editModes[i] = true;
                                              });
                                            },
                                            backgroundColor: const Color(0xFF006FFD).withOpacity(0.1),
                                            foregroundColor: const Color(0xFF006FFD),
                                            icon: Icons.edit,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          SlidableAction(
                                            onPressed: (_) {
                                              setState(() {
                                                if (i >= 0 && i < _schedules.length && i < _editModes.length) {
                                                  _schedules.removeAt(i);
                                                  _editModes.removeAt(i);
                                                }
                                              });
                                            },
                                            backgroundColor: Colors.red.shade50,
                                            foregroundColor: Colors.red,
                                            icon: Icons.delete_outline,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ],
                                      ),
                                      child: ListTile(
                                        leading: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF006FFD).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Icon(Icons.event_note, color: Color(0xFF006FFD), size: 20),
                                        ),
                                        title: Text('${_fmt(s.start)} ~ ${_fmt(s.end)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        subtitle: Text('${_dateFmt.format(s.date)}  |  ${s.title}', softWrap: true, overflow: TextOverflow.visible),
                                        isThreeLine: true,
                                      ),
                                    );
                            },
                          ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveToServer,
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('캘린더로 이동'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006FFD),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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
  }
}
