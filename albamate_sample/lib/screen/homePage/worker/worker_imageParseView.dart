import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'worker_homecalendar.dart';
import 'worker_imageProcessing.dart'; // Schedule

class WorkerImageParseViewPage extends StatelessWidget {
  final File imageFile;
  final List<Schedule> schedules;

  WorkerImageParseViewPage({
    super.key,
    required this.imageFile,
    required this.schedules,
  });

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  final _dateFmt = DateFormat('M월 d일 (E)', 'ko');

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: const Text('스케줄 추출 결과')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /* ▸ AI 분석 정보 */
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
                          '🤖 Gemini 2.5 Flash Lite AI 분석',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF006FFD),
                          ),
                        ),
                        Text(
                          '${schedules.length}개의 일정이 추출되었습니다',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            /* ▸ 사진(고정) */
            Container(
              height: h * 0.35, // 높이 조정
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: InteractiveViewer(
                  child: Image.file(imageFile, fit: BoxFit.contain),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '추출된 일정',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),

            /* ▸ 리스트만 스크롤 (Expanded) */
            Expanded(
              child:
                  schedules.isEmpty
                      ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline, size: 48, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              '추출된 일정이 없습니다.',
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '이미지를 다시 확인해주세요.',
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                      )
                      : ListView.separated(
                        itemCount: schedules.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final s = schedules[i];
                          return ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF006FFD).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.event_note,
                                color: Color(0xFF006FFD),
                                size: 20,
                              ),
                            ),
                            title: Text(
                              '${_fmt(s.start)} ~ ${_fmt(s.end)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${_dateFmt.format(s.date)}  |  ${s.title}',
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                            isThreeLine: true,
                          );
                        },
                      ),
            ),
            const SizedBox(height: 12),

            /* ▸ 캘린더로 이동 */
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WorkerHomecalendar(),
                      ),
                      (route) => false,
                    ),
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
    );
  }
}
