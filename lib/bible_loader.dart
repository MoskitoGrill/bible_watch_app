import 'dart:convert';
import 'package:flutter/services.dart';

class BibleLoader {
  static Future<Map<String, dynamic>> _loadBibleJson() async {
    final String response = await rootBundle.loadString('assets/bible_CSP.json');
    return json.decode(response);
  }

  static Future<List<String>> loadBooks() async {
    final jsonData = await _loadBibleJson();
    return jsonData.keys.toList();
  }

  static Future<List<String>> loadChapters(String book) async {
    final Map<String, dynamic> data = await _loadBibleJson();
    return (data[book] as Map<String, dynamic>).keys.toList();
  }

  static Future<List<String>> loadVerses(String book, String chapter) async {
    final Map<String, dynamic> data = await _loadBibleJson();
    return (data[book][chapter] as Map<String, dynamic>).keys.toList();
  }

  static Future<String> loadVerseText(String book, String chapter, String verse) async {
    final Map<String, dynamic> data = await _loadBibleJson();
    return data[book][chapter][verse];
  }
}
