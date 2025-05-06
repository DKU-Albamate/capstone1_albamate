import 'package:flutter/material.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
import 'package:albamate_sample/screen/groupPage/notice/notice_model.dart';
import 'package:albamate_sample/component/groupHome_navigation.dart';

//안내사항 상세 페이지
class DetailGuidePage extends StatefulWidget {
  final Notice notice;

  const DetailGuidePage({required this.notice});

  @override
  State<DetailGuidePage> createState() => _DetailGuidePageState();
}

class _DetailGuidePageState extends State<DetailGuidePage> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('안내사항', style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: "Inter",
            color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(icon: Icon(Icons.home),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => GroupNav(groupId : widget.notice.groupId)),
                  (Route<dynamic> route) => false,
                );
          }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(backgroundColor: Colors.grey[300], radius: 20),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.notice.title,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text(widget.notice.date, style: TextStyle(color: Colors.grey)),
                  ],
                ),
                Spacer(),
                Icon(Icons.more_vert)
              ],
            ),
            SizedBox(height: 20),
            Text(widget.notice.content),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Row(
            children: [
              MSHCheckbox(
                size: 22,
                value: isChecked,
                colorConfig: MSHColorConfig.fromCheckedUncheckedDisabled(
                  checkedColor: Colors.blue,
                ),
                style: MSHCheckboxStyle.fillScaleColor,
                onChanged: (selected) {
                  setState(() {
                    isChecked = selected;
                  });
                },
              ),
              SizedBox(width: 8),
              Text('확인', style: TextStyle(color: Colors.grey[800]))
            ],
          ),
        ),
      ),
    );
  }
}
