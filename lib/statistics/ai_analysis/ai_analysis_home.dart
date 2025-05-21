import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart'; //이모지
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, dynamic>> fetchMonthlyReport(String userId) async {
  final response = await http.get(Uri.parse('http://10.0.2.2:8080/note/report/monthly/$userId'));
  print("요청 URL: http://<서버주소>/note/report/monthly/$userId");

  if(response.statusCode==200){
    final decoded = utf8.decode(response.bodyBytes);
    print("상태 코드: ${response.statusCode}");
    print("응답 본문: ${response.body}");
    return jsonDecode(decoded);
  }else{
    throw Exception("월간 리포트 불러오기 실패 : ${response.body}");
  }
}
class AIAnalysisHomePage extends StatefulWidget {
  const AIAnalysisHomePage({super.key});

  @override
  State<AIAnalysisHomePage> createState() => _AIAnalysisHomePageState();
}
class _AIAnalysisHomePageState extends State<AIAnalysisHomePage>{
  Map<String, dynamic>? report;
  @override
  void initState(){
    super.initState();
      loadReport();
  }
  void loadReport() async{
    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');

    if(userID == null){
      print("Id가 없음");
      return;
    }

    try{
      final data = await fetchMonthlyReport(userID.toString());
      setState(() {
        report = data;
      });
    }catch(e){
      print("리포트 불러오기 오류: $e");
    }
  }
  Future<void> sendFeedback(int noteId, bool agree) async{
    try{
      final response = await http.post(Uri.parse('http://10.0.2.2:8080/note/report/feedback'),headers: {'Content-Type':'application/json'},body: jsonEncode({'noteId':noteId,'agree':agree}),);

      if(response.statusCode == 200){
        print('피드백 전송 성공');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("피드백이 전송되었습니다.")),
        );
      }else{
        print("피드백 실패 : ${response.statusCode}");
      }
    }catch(e){
      print("예외 발생 : $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    if(report == null){
      return Scaffold(
        appBar: AppBar(title: Text('AI 분석')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    
    final suggestions = report!['suggestion'].toString().split(' / ');
    final byCategory = report!['byCategory'];

    return Scaffold(
      appBar: AppBar(title: Text('AI 분석')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text("${report!['month']} 리포트"),
          SizedBox(height: 10),
          Text("총 지출 : ${report!['totalAmount']}원"),
          Text("이상 소비 : ${report!['anomalyCount']}건, 과소비 : ${report!['overspendingCount']}건"),
          SizedBox(height: 20),
          Text("소비 분석 리포트",),
          ...suggestions.map((s) => Padding(padding: EdgeInsets.symmetric(vertical: 4),child: Text("📍 $s"))),
          SizedBox(height: 20),
          Text("카테고리별 통계"),
          ...byCategory.map<Widget>((cat) {
            final flaggedItems = cat['flaggedItems']??[];
            return  Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cat['category'] ?? "카테고리 없음"),
                        Text("총 지출 : ${cat['totalAmount']}원 | 이상소비: ${cat['anomalyCount']}건 | 과소비: ${cat['overspendingCount']}건"),
                        SizedBox(height: 8),
                        ...flaggedItems.map<Widget>((item) => Card(
                          child: ListTile(
                            title: Text("${item['content']?.isNotEmpty ==true ?item['content']: "내용 없음"} - ${item['amount'] ?? 0}원"),
                            subtitle: Text("${item['date'] ?? "-"} /" "${item['isAnomaly'] == true ? '이상소비' : item['isOverspending'] == true ? '과소비' : ''}"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: item['userFeedback'] == null
                                    ? () async {
                                    await sendFeedback(item['id'], true);
                                    setState(() {
                                      item['userFeedback'] =true;
                                    });
                                    }
                                    :null,
                                  icon: Icon(Icons.thumb_up),
                                ),
                                IconButton(
                                  onPressed: item['userFeedback'] == null
                                      ? () async {
                                    await sendFeedback(item['id'], false);
                                    setState(() {
                                      item['userFeedback'] =false;
                                    });
                                  }
                                      :null,
                                  icon: Icon(Icons.thumb_down),
                                ),
                              ],
                            ),
                          ),
                        )),
                      ],
                    ),
              ),
            );
          }),
        ],
      ),
      // body: ListView.builder(
      //   padding: EdgeInsets.all(16),
      //   itemCount: feedbacks.length,
      //   itemBuilder: (context, index) => Container(
      //     margin: EdgeInsets.only(bottom: 16),
      //     padding: EdgeInsets.all(16),
      //     decoration: BoxDecoration(
      //       color: Colors.amber.shade50,
      //       borderRadius: BorderRadius.circular(12),
      //     ),
      //     child: Column(
      //       crossAxisAlignment: CrossAxisAlignment.start,
      //       children: [
      //         Text(feedbacks[index]['title']!, style: TextStyle(fontWeight: FontWeight.bold)),
      //         SizedBox(height: 8),
      //         Text(feedbacks[index]['content']!),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}
