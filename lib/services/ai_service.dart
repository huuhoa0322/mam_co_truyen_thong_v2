import 'dart:convert';
import 'dart:developer' as developer;

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiIngredientDraft {
  final String name;
  final double amount;
  final String unit;
  final String? notes;

  const AiIngredientDraft({
    required this.name,
    required this.amount,
    required this.unit,
    this.notes,
  });
}

class AiStepDraft {
  final String title;
  final String description;
  final int? timerMinutes;

  const AiStepDraft({
    required this.title,
    required this.description,
    this.timerMinutes,
  });
}

class AiSecretDraft {
  final String title;
  final String content;
  final List<String> tags;

  const AiSecretDraft({
    required this.title,
    required this.content,
    required this.tags,
  });
}

class AiIngredientPriceDraft {
  final String ingredientName;
  final int estimatedPrice;

  const AiIngredientPriceDraft({
    required this.ingredientName,
    required this.estimatedPrice,
  });
}

class AiService {
  late GenerativeModel _model;

  AiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      // In case it's not set correctly, use a default fallback or throw.
      // We will print a warning but not crash immediately, allowing UI to handle nulls if it fails later.
      developer.log(
        'WARNING: GEMINI_API_KEY is missing or empty in .env',
        name: 'AiService',
      );
    }
    _model = GenerativeModel(
      model: 'gemini-2.5-flash', 
      apiKey: apiKey ?? '',
    );
  }

  Future<List<String>> suggestIngredients(String dishName) async {
    final drafts = await suggestIngredientDrafts(dishName);
    return drafts.map((e) => e.name).toList();
  }

  Future<List<String>> suggestSteps(String dishName) async {
    final drafts = await suggestStepDrafts(dishName);
    return drafts.map((e) => e.description).toList();
  }

  Future<String?> suggestSecrets(String dishName) async {
    final draft = await suggestSecretDraft(dishName);
    return draft?.content;
  }

  Future<List<AiIngredientDraft>> suggestIngredientDrafts(String dishName) async {
    final prompt =
        'Bạn là một đầu bếp truyền thống Việt Nam kỳ cựu với nhiều năm kinh nghiệm nấu các món ăn gia đình. '
        'Người dùng đang cần sự giúp đỡ chuẩn bị nguyên liệu cho món "$dishName". '
        'Hãy liệt kê ĐẦY ĐỦ các nguyên liệu cần thiết, bao gồm cả gia vị nhỏ, '
        'với số lượng và đơn vị cụ thể phù hợp với khẩu phần của người ăn. '
        'Trả về DUY NHẤT một JSON array, mỗi phần tử là object với các key sau: '
        '"name" (string – tên nguyên liệu tiếng Việt), '
        '"amount" (number – số lượng), '
        '"unit" (string – đơn vị: g, kg, ml, l, quả, lạng, muỗng cà phê, muỗng súp, ...), '
        '"notes" (string – mẹo chọn nguyên liệu hoặc ghi chú thêm, để rỗng nếu không có). '
        'CHỈ trả về JSON array, KHÔNG markdown, KHÔNG giải thích, KHÔNG thêm văn bản trước/sau JSON.';
    final result = await _generate(prompt);
    final json = _extractJson(result);
    if (json == null) return [];

    try {
      final decoded = jsonDecode(json);
      if (decoded is! List) return [];

      final drafts = <AiIngredientDraft>[];
      for (final item in decoded) {
        if (item is! Map) continue;
        final name = (item['name'] ?? '').toString().trim();
        final unit = (item['unit'] ?? '').toString().trim();
        final amount = _toDouble(item['amount']);
        final notesRaw = (item['notes'] ?? '').toString().trim();
        if (name.isEmpty || unit.isEmpty || amount <= 0) continue;

        drafts.add(
          AiIngredientDraft(
            name: name,
            amount: amount,
            unit: unit,
            notes: notesRaw.isEmpty ? null : notesRaw,
          ),
        );
      }
      return drafts;
    } catch (_) {
      return [];
    }
  }

  Future<List<AiStepDraft>> suggestStepDrafts(String dishName) async {
    final prompt =
        'Bạn là một đầu bếp truyền thống Việt Nam kỳ cựu, thuộc lòng từng bước chuẩn bị và nấu món ăn gia truyền. '
        'Hãy hướng dẫn cách làm món "$dishName" theo từng bước rõ ràng, sắp xếp theo trình tự thực tế. '
        'Mỗi bước nên bao gồm thao tác cụ thể và thời gian ước lượng. '
        'Trả về DUY NHẤT một JSON array, mỗi phần tử là object với các key sau: '
        '"title" (string – tên ngắn gọn của bước, ví dụ: "Sơ chế rau", "Ướp thịt", "Xào trên lửa lớn"), '
        '"description" (string – mô tả chi tiết các thao tác trong bước đó), '
        '"timerMinutes" (number – thời gian tính bằng phút NẾU cần hẹn giờ, hoặc null nếu không cần). '
        'CHỈ trả về JSON array, KHÔNG markdown, KHÔNG giải thích, KHÔNG thêm văn bản trước/sau JSON.';
    final result = await _generate(prompt);
    final json = _extractJson(result);
    if (json == null) return [];

    try {
      final decoded = jsonDecode(json);
      if (decoded is! List) return [];

      final drafts = <AiStepDraft>[];
      for (final item in decoded) {
        if (item is! Map) continue;
        final title = (item['title'] ?? '').toString().trim();
        final description = (item['description'] ?? '').toString().trim();
        final timerMinutes = _toInt(item['timerMinutes']);
        if (title.isEmpty || description.isEmpty) continue;

        drafts.add(
          AiStepDraft(
            title: title,
            description: description,
            timerMinutes: (timerMinutes != null && timerMinutes > 0) ? timerMinutes : null,
          ),
        );
      }
      return drafts;
    } catch (_) {
      return [];
    }
  }

  Future<AiSecretDraft?> suggestSecretDraft(String dishName) async {
    final prompt =
        'Bạn là một bà nội/mẹ với nhiều năm nấu ăn gia đình, nắm giữ những bí kíp nấu ăn gia truyền quý giá '
        'được truyền lại qua nhiều thế hệ. '
        'Hãy chia sẻ MỘT bí kíp quan trọng nhất để nấu món "$dishName" thật ngon và đặc trưng gia đình. '
        'Bí kíp nên cụ thể, thiết thực và chứa đựng kinh nghiệm thực tế (không phải lý thuyết chung chung). '
        'Trả về DUY NHẤT một JSON object với các key sau: '
        '"title" (string – tiêu đề bí kíp, ví dụ: "Mẹo ướp thịt của Bà", "Bí quyết nước dùng trong"), '
        '"content" (string – nội dung bí kíp chi tiết, viết theo phong cách kể chuyện thân thuộc), '
        '"tags" (array of string – 3–5 từ khoá liên quan, ví dụ: ["ướp gia vị", "chọn nguyên liệu"]). '
        'CHỈ trả về JSON object, KHÔNG markdown, KHÔNG giải thích, KHÔNG thêm văn bản trước/sau JSON.';
    final result = await _generate(prompt);
    final json = _extractJson(result);
    if (json == null) return null;

    try {
      final decoded = jsonDecode(json);
      if (decoded is! Map) return null;

      final title = (decoded['title'] ?? '').toString().trim();
      final content = (decoded['content'] ?? '').toString().trim();
      final tagsRaw = decoded['tags'];
      final tags = <String>[];
      if (tagsRaw is List) {
        for (final tag in tagsRaw) {
          final value = tag.toString().trim();
          if (value.isNotEmpty) tags.add(value);
        }
      }

      if (content.isEmpty) return null;
      return AiSecretDraft(
        title: title.isEmpty ? 'Bí kíp gia truyền' : title,
        content: content,
        tags: tags,
      );
    } catch (_) {
      return null;
    }
  }

  Future<String?> estimateCost(String dishName, List<String> ingredients) async {
    final ingredientsList = ingredients.isEmpty ? 'Chưa rõ' : ingredients.join(', ');
    final prompt = 'Dựa trên món "$dishName" và danh sách nguyên liệu: $ingredientsList. Hãy ước tính tổng chi phí dự kiến để đi chợ (theo VNĐ). Chỉ trả về một con số và đơn vị VNĐ (Ví dụ: 150.000 VNĐ) hoặc khoảng giá dự tính (Ví dụ: 100.000 - 150.000 VNĐ), tuyệt đối không giải thích hay mở bài/kết bài.';
    return _generate(prompt);
  }

  Future<List<AiIngredientPriceDraft>> suggestIngredientPriceDrafts(
    String dishName,
    List<String> ingredients,
  ) async {
    if (ingredients.isEmpty) return [];

    final ingredientList = ingredients.map((e) => '- $e').join('\n');
    final prompt =
        'Bạn là một người nội trợ Việt Nam kinh nghiệm, thường xuyên đi chợ và nắm rõ giá cả thị trường hiện tại. '
        'Hãy ước tính GIÁ MUA tại chợ (tính bằng VNĐ) cho từng nguyên liệu dưới đây, '
        'phù hợp với món "$dishName". '
        'Sử dụng mức giá trung bình tại chợ truyền thống ở Việt Nam (không phải siêu thị cao cấp). '
        'Danh sách nguyên liệu:\n$ingredientList\n'
        'Trả về DUY NHẤT một JSON array, mỗi phần tử là object với các key sau: '
        '"ingredientName" (string – tên nguyên liệu, viết lại đúng chính xác như trong danh sách), '
        '"estimatedPrice" (integer – giá ước tính tính bằng VNĐ cho số lượng đã cho, là số nguyên). '
        'CHỈ trả về JSON array, KHÔNG markdown, KHÔNG giải thích, KHÔNG thêm văn bản trước/sau JSON.';

    final result = await _generate(prompt);
    final json = _extractJson(result);
    if (json == null) return [];

    try {
      final decoded = jsonDecode(json);
      if (decoded is! List) return [];

      final drafts = <AiIngredientPriceDraft>[];
      for (final item in decoded) {
        if (item is! Map) continue;
        final name = (item['ingredientName'] ?? '').toString().trim();
        final price = _toInt(item['estimatedPrice']) ?? 0;
        if (name.isEmpty || price <= 0) continue;
        drafts.add(
          AiIngredientPriceDraft(
            ingredientName: name,
            estimatedPrice: price,
          ),
        );
      }
      return drafts;
    } catch (_) {
      return [];
    }
  }

  Future<String?> _generate(String prompt) async {
    try {
      if (dotenv.env['GEMINI_API_KEY'] == null || dotenv.env['GEMINI_API_KEY']!.isEmpty || dotenv.env['GEMINI_API_KEY'] == 'your_gemini_api_key_here') {
        developer.log(
          'Error: API key not configured properly.',
          name: 'AiService',
          level: 1000,
        );
        return null; // Return null gracefully so UI knows it failed (could show toast)
      }
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text?.trim();
    } catch (e) {
      developer.log(
        'AI Error: $e',
        name: 'AiService',
        level: 1000,
      );
      return null;
    }
  }

  String? _extractJson(String? raw) {
    if (raw == null) return null;
    final text = raw.trim();
    if (text.isEmpty) return null;

    final firstBrace = text.indexOf('{');
    final firstBracket = text.indexOf('[');
    final starts = [firstBrace, firstBracket].where((e) => e >= 0).toList();
    if (starts.isEmpty) return null;

    final start = starts.reduce((a, b) => a < b ? a : b);
    final lastBrace = text.lastIndexOf('}');
    final lastBracket = text.lastIndexOf(']');
    final end = (lastBrace > lastBracket ? lastBrace : lastBracket);
    if (end < start) return null;

    return text.substring(start, end + 1).trim();
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    final raw = value?.toString().trim() ?? '';
    if (raw.isEmpty) return 0;
    return double.tryParse(raw.replaceAll(',', '.')) ?? 0;
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    final raw = value?.toString().trim() ?? '';
    if (raw.isEmpty || raw.toLowerCase() == 'null') return null;
    return int.tryParse(raw);
  }
}
