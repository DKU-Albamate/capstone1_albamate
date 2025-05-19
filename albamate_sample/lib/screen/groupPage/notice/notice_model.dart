class Notice {
  final String id;
  final String title;
  final String content;
  final String authorUid;
  final String groupId;
  final String category;
  final String createdAt; // 추가
  final String? imageUrl;  // 추가

  Notice({
    required this.id,
    required this.title,
    required this.content,
    required this.authorUid,
    required this.groupId,
    required this.category,
    required this.createdAt,
    this.imageUrl, // 추가
  });

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      authorUid: json['author_uid'],
      groupId: json['group_id'],
      category: json['category'],
      createdAt: json['created_at'], // 받아오기
      imageUrl: json['image_url'], // 추가
    );
  }
}

