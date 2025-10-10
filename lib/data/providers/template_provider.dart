import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_template.dart';

class TemplateProvider with ChangeNotifier {
  static const _templatesKey = 'transaction_templates';

  List<TransactionTemplate> _templates = [];

  List<TransactionTemplate> get templates => [..._templates];

  Future<void> loadTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final templatesString = prefs.getString(_templatesKey);
    if (templatesString != null) {
      final List<dynamic> decoded = json.decode(templatesString);
      _templates = decoded
          .map((item) => TransactionTemplate.fromJson(item))
          .toList();
      notifyListeners();
    }
  }

  Future<void> _saveTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final templatesString = json.encode(
      _templates.map((t) => t.toJson()).toList(),
    );
    await prefs.setString(_templatesKey, templatesString);
  }

  Future<void> addTemplate(TransactionTemplate template) async {
    _templates.add(template);
    await _saveTemplates();
    notifyListeners();
  }

  Future<void> updateTemplate(
    String id,
    TransactionTemplate newTemplate,
  ) async {
    final index = _templates.indexWhere((t) => t.id == id);
    if (index != -1) {
      _templates[index] = newTemplate;
      await _saveTemplates();
      notifyListeners();
    }
  }

  Future<void> deleteTemplate(String id) async {
    _templates.removeWhere((t) => t.id == id);
    await _saveTemplates();
    notifyListeners();
  }

  Future<void> clearAllData() async {
    _templates = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_templatesKey);
    notifyListeners();
  }
}
