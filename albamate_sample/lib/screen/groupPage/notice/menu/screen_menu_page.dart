import 'package:flutter/material.dart';
import 'create_menu_page.dart';
import 'detail_menu_page.dart';
import 'package:albamate_sample/screen/groupPage/notice/notice_model.dart';


//신메뉴 공지 화면 페이지
class ScreenMenuPage extends StatefulWidget {
  final String groupId; // ✅ 추가

  const ScreenMenuPage({required this.groupId, Key? key}) : super(key: key);

  @override
  _ScreenMenuPageState createState() => _ScreenMenuPageState();
}

class _ScreenMenuPageState extends State<ScreenMenuPage> {
  // 작성된 공지를 저장하는 리스트
  List<Notice> notices = [];

  // 새로운 공지를 추가하는 함수
  void _addNotice(Notice notice) {
    setState(() {
      notices.add(notice);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: notices.length,
        itemBuilder: (context, index) {
          final notice = notices[index];
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            width: double.infinity,
            height: 148,
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.notifications_none, color: Colors.grey[700], size: 28),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailMenuPage(notice: notice),
                                  ),
                                );
                              },
                              //제목 클릭시 상세 페이지로 이동
                              child : Text(
                                notice.title,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                              SizedBox(height: 4),
                              Text(
                                notice.date,
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        // 수정/삭제 버튼
                        PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'edit') {
                              final editedNotice = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreateMenuPage(groupId: widget.groupId),
                                ),
                              );
                              if (editedNotice != null && editedNotice is Notice) {
                                setState(() {
                                  notices[index] = editedNotice;
                                });
                              }
                            } else if (value == 'delete') {
                              setState(() {
                                notices.removeAt(index);
                              });
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(value: 'edit', child: Text('수정하기')),
                            PopupMenuItem(value: 'delete', child: Text('삭제하기')),
                          ],
                          icon: Icon(Icons.more_vert),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    // 제목이나 내용을 누르면 상세 페이지로 이동
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailMenuPage(notice: notice),
                            ),
                          );
                        },
                        child: Text(
                          notice.content,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 4,
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
      // 공지 작성 버튼
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Color(0xFF006FFD),
        onPressed: () async {
          final newNotice = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateMenuPage(groupId: widget.groupId)),
          );

          if (newNotice != null && newNotice is Notice) {
            _addNotice(newNotice);
          }
        },
        label: Text('Create', style: TextStyle(color: Colors.white)),
        icon: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
