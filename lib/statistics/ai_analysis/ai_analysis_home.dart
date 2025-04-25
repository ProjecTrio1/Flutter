import 'package:flutter/material.dart';

class AIAnalysisHomePage extends StatelessWidget {
  const AIAnalysisHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> feedbacks = [
      {'title': '3월 소비 분석', 'content': '의류 지출이 높습니다. 비슷한 옷 중복구매 주의!'},
      {'title': '식비 경고', 'content': '배달음식 소비가 많습니다. 요리 추천을 확인해보세요.'},
    ];

    return Scaffold(
      appBar: AppBar(title: Text('AI 분석')),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: feedbacks.length,
        itemBuilder: (context, index) => Container(
          margin: EdgeInsets.only(bottom: 16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(feedbacks[index]['title']!, style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(feedbacks[index]['content']!),
            ],
          ),
        ),
      ),
    );
  }
}
