import 'package:flutter/material.dart';
import 'package:albamate_sample/screen/groupPage/notice/guide/screen_guide_page.dart';
import 'package:albamate_sample/screen/groupPage/notice/menu/screen_menu_page.dart';
import 'package:albamate_sample/screen/groupPage/notice/sub/screen_sub_page.dart';

//공지사항 내 탭 구조
class NoticePageNav extends StatefulWidget {
  final String groupId; // ✅ 추가

  const NoticePageNav({required this.groupId, Key? key}) : super(key: key);
  @override
  _NoticePageNavState createState() => _NoticePageNavState();
}

class _NoticePageNavState extends State<NoticePageNav> {
  int _selectedIndex = 0;

  //탭 변경
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    //각 탭에 대응되는 하위 페이지
    final List<Widget> _pages = [
      ScreenGuidePage(groupId: widget.groupId),
      ScreenSubPage(groupId: widget.groupId),
      ScreenMenuPage(groupId: widget.groupId),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('공지사항',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: "Inter",
                color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // 탭 버튼 영역
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              width: double.infinity,
              height: 39,
              decoration: BoxDecoration(
                color: Color(0xffF8F9FE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTabButton("안내사항", 0),
                  SizedBox(width: 10),
                  _buildTabButton("대타 구하기", 1),
                  SizedBox(width: 10),
                  _buildTabButton("신메뉴 공지", 2),
                ],
              ),
            ),
          ),
          //현재 선택된 탭에 따라 화면 출력됨
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }

  //탭 버튼 생성 함수
  Widget _buildTabButton(String text, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        width: 100,
        height: 31,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Color(0xffF8F9FE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Color(0xff1F2024) : Color(0xff71727A),
            ),
          ),
        ),
      ),
    );
  }
}