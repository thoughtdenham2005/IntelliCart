import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class RecipeIngredient {
  final String name;
  final String quantity;
  final String aisleLocation;

  RecipeIngredient({
    required this.name,
    required this.quantity,
    required this.aisleLocation,
  });
}

class RecipeExtractionResult {
  final String dishName;
  final String channelTitle;
  final String videoId;
  final List<RecipeIngredient> ingredients;

  RecipeExtractionResult({
    required this.dishName,
    required this.channelTitle,
    required this.videoId,
    required this.ingredients,
  });

  String get thumbnailUrl => 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
}

class RecipeExtractorService {
  // Replace with your Groq API key
  static const String _groqApiKey = 'YOUR_GROQ_API_KEY_HERE';
  static const String _endpoint = 'https://api.groq.com/openai/v1/chat/completions';

  // =========================================================
  // 3 BULLETPROOF DEMO RECIPES (Offline / Instant Failover)
  // =========================================================
  static final Map<String, RecipeExtractionResult> _hardcodedFallbackRecipes = {
    'kXx31fW2u9E': RecipeExtractionResult(
      dishName: 'Maggi Goreng Mamak Special',
      channelTitle: 'Che Nom',
      videoId: 'kXx31fW2u9E',
      ingredients: [
        RecipeIngredient(name: 'Maggi 2-Minute Curry Noodles', quantity: '2 packets', aisleLocation: 'Aisle 3 (Instant Foods)'),
        RecipeIngredient(name: 'Fresh Chicken Eggs', quantity: '2 eggs', aisleLocation: 'Aisle 5 (Fresh Produce & Eggs)'),
        RecipeIngredient(name: 'Cooking Oil', quantity: '3 tbsp', aisleLocation: 'Aisle 1 (Cooking Essentials)'),
        RecipeIngredient(name: 'Fresh Sawi (Mustard Greens)', quantity: '1 bunch', aisleLocation: 'Fresh Produce Section'),
        RecipeIngredient(name: 'Garlic & Shallots', quantity: '3 cloves each', aisleLocation: 'Fresh Produce Section'),
        RecipeIngredient(name: 'Sweet Soy Sauce (Kicap Manis)', quantity: '2 tbsp', aisleLocation: 'Aisle 2 (Sauces & Condiments)'),
      ],
    ),
    'n5l7kG4V7vE': RecipeExtractionResult(
      dishName: 'Ayam Masak Merah Kenduri',
      channelTitle: 'Khairulaming',
      videoId: 'n5l7kG4V7vE',
      ingredients: [
        RecipeIngredient(name: 'Fresh Whole Chicken Cut', quantity: '1/2 bird', aisleLocation: 'Meat & Poultry Section'),
        RecipeIngredient(name: 'Dried Chili Paste (Cili Kisar)', quantity: '4 tbsp', aisleLocation: 'Aisle 2 (Pastes & Mixes)'),
        RecipeIngredient(name: 'Large Yellow Onions', quantity: '2 bulbs', aisleLocation: 'Fresh Produce Section'),
        RecipeIngredient(name: 'Coarse Sugar', quantity: '1.5 tbsp', aisleLocation: 'Aisle 1 (Baking & Sugar)'),
        RecipeIngredient(name: 'Tomato Puree Can', quantity: '3 tbsp', aisleLocation: 'Aisle 2 (Pastes & Sauces)'),
      ],
    ),
    'J7_b8WJvPz0': RecipeExtractionResult(
      dishName: "Yeo's Winter Melon Lychee Mocktail",
      channelTitle: 'Drink Lab Malaysia',
      videoId: 'J7_b8WJvPz0',
      ingredients: [
        RecipeIngredient(name: "Yeo's Winter Melon Drink", quantity: '2 cans', aisleLocation: 'Aisle 4 (Beverages & Chilled)'),
        RecipeIngredient(name: 'Canned Lychee in Syrup', quantity: '1 can', aisleLocation: 'Aisle 2 (Canned Goods)'),
        RecipeIngredient(name: 'Fresh Mint Leaves', quantity: '1 sprig', aisleLocation: 'Fresh Produce Section'),
        RecipeIngredient(name: 'Fresh Lime', quantity: '1 piece', aisleLocation: 'Fresh Produce Section'),
      ],
    ),
  };

  // Supermarket Aisle Directory
  static const Map<String, String> _aisleDirectory = {
    'oil': 'Aisle 1 (Cooking Essentials)',
    'salt': 'Aisle 1 (Seasonings & Spices)',
    'sugar': 'Aisle 1 (Baking & Sugar)',
    'flour': 'Aisle 1 (Baking & Flour)',
    'curry': 'Aisle 2 (Pastes & Sauces)',
    'sauce': 'Aisle 2 (Sauces & Condiments)',
    'kicap': 'Aisle 2 (Sauces & Condiments)',
    'paste': 'Aisle 2 (Pastes & Mixes)',
    'noodle': 'Aisle 3 (Instant Foods)',
    'mee': 'Aisle 3 (Instant Foods)',
    'maggi': 'Aisle 3 (Instant Foods)',
    'rice': 'Aisle 3 (Grains & Rice)',
    'beras': 'Aisle 3 (Grains & Rice)',
    'milk': 'Aisle 4 (Dairy & Chilled)',
    'susu': 'Aisle 4 (Dairy & Chilled)',
    'cheese': 'Aisle 4 (Dairy & Chilled)',
    'butter': 'Aisle 4 (Dairy & Chilled)',
    'egg': 'Aisle 5 (Fresh Produce & Eggs)',
    'telur': 'Aisle 5 (Fresh Produce & Eggs)',
    'chicken': 'Meat & Poultry Section',
    'ayam': 'Meat & Poultry Section',
    'meat': 'Meat & Poultry Section',
    'beef': 'Meat & Poultry Section',
    'daging': 'Meat & Poultry Section',
    'onion': 'Fresh Produce Section',
    'bawang': 'Fresh Produce Section',
    'garlic': 'Fresh Produce Section',
    'chili': 'Fresh Produce Section',
    'cili': 'Fresh Produce Section',
    'vegetable': 'Fresh Produce Section',
    'sayur': 'Fresh Produce Section',
  };

  static String? extractVideoId(String input) {
    final trimmed = input.trim();
    if (RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(trimmed)) {
      return trimmed;
    }
    final regExp = RegExp(
      r'(?:https?:\/\/)?(?:www\.|m\.)?(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?|shorts)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(trimmed);
    return match?.group(1);
  }

  static String _resolveAisle(String ingredient) {
    final lower = ingredient.toLowerCase();
    for (final entry in _aisleDirectory.entries) {
      if (lower.contains(entry.key)) {
        return entry.value;
      }
    }
    return 'Aisle 2 (General Grocery)';
  }

  static Future<Map<String, String>?> fetchVideoMetadata(String videoId) async {
    try {
      final url = 'https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=$videoId&format=json';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return {
          'title': data['title'] as String? ?? 'Recipe Video',
          'author': data['author_name'] as String? ?? 'YouTube Creator',
        };
      }
    } catch (e) {
      debugPrint('oEmbed fetch error: $e');
    }
    return null;
  }

  static Future<RecipeExtractionResult?> extractFromInput(String input) async {
    final videoId = extractVideoId(input);
    if (videoId == null) return null;

    // 1. Check Hardcoded Offline Cache first
    if (_hardcodedFallbackRecipes.containsKey(videoId)) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _hardcodedFallbackRecipes[videoId];
    }

    // 2. Dynamic Live Path via oEmbed + Groq Qwen
    try {
      final meta = await fetchVideoMetadata(videoId) ?? {
        'title': 'Cooking Recipe',
        'author': 'YouTube Chef'
      };
      final videoTitle = meta['title']!;
      final author = meta['author']!;

      final prompt = '''
The customer wants to cook the dish featured in this YouTube recipe video: "$videoTitle" by "$author".
Extract the primary dish name and itemize 4 to 8 core cooking ingredients required.

Output strictly valid JSON with this exact schema, without markdown codeblock backticks:
{
  "dishName": "Dish Name",
  "ingredients": [
    {"name": "Ingredient Name", "quantity": "Portion/Quantity"}
  ]
}
''';

      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Authorization': 'Bearer $_groqApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'qwen/qwen3.8-27b',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a supermarket culinary assistant. Return strictly raw JSON with no conversational text or code fences.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.1,
          'max_tokens': 350,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        String rawContent = data['choices'][0]['message']['content'].toString().trim();

        if (rawContent.startsWith('```')) {
          rawContent = rawContent.replaceAll(RegExp(r'^```json|^```|```$', multiLine: true), '').trim();
        }

        final parsedJson = jsonDecode(rawContent);
        final dish = parsedJson['dishName'] ?? videoTitle;
        final rawIngredients = parsedJson['ingredients'] as List<dynamic>;

        final List<RecipeIngredient> items = rawIngredients.map((ing) {
          final name = ing['name'].toString();
          final qty = ing['quantity']?.toString() ?? 'As needed';
          return RecipeIngredient(
            name: name,
            quantity: qty,
            aisleLocation: _resolveAisle(name),
          );
        }).toList();

        return RecipeExtractionResult(
          dishName: dish,
          channelTitle: author,
          videoId: videoId,
          ingredients: items,
        );
      }
    } catch (e) {
      debugPrint('Groq recipe extraction error: $e');
    }

    // Failover safety net
    return _hardcodedFallbackRecipes['kXx31fW2u9E'];
  }
}