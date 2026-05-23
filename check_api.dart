import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url2 = Uri.parse('https://api.alquran.cloud/v1/surah/2');
  final res2 = await http.get(url2);
  final data2 = json.decode(res2.body);
  print('Surah 2 Ayah 1:');
  print(data2['data']['ayahs'][0]['text']);
  
  final url3 = Uri.parse('https://api.alquran.cloud/v1/surah/3');
  final res3 = await http.get(url3);
  final data3 = json.decode(res3.body);
  print('Surah 3 Ayah 1:');
  print(data3['data']['ayahs'][0]['text']);
}
