import 'dart:convert';
import 'package:http/http.dart' as http;

class GroqService {
  // Replace with your Groq API key from console.groq.com
  static const String _apiKey = 'YOUR_GROQ_API_KEY';
  static const String _endpoint = 'YOUR_GROQ_ENDPOINT';

  static Future<String> getProductInsights(String productName) async {
    final systemPrompt = '''
You are IntelliCart AI, a fast, knowledgeable supermarket assistant on an in-store shopping tablet in Malaysia.
When given a product name, provide a concise, customer-friendly breakdown with exactly three bullet points:
1. Key Ingredients (Main ingredients only)
2. Potential Allergens (e.g., Gluten, Soy, Dairy, Nuts)
3. Halal Status & Dietary Notes (Mention JAKIM Halal suitability in Malaysia if applicable)

Keep the answer scannable, under 80 words, and formatted neatly with bold headings. Avoid generic conversational fluff.
''';

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'qwen/qwen3.8-27b',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': 'Tell me about: $productName'},
          ],
          'temperature': 0.2,
          'max_tokens': 250,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'];
      } else {
        return 'Error fetching AI details (${response.statusCode}): ${response.reasonPhrase}';
      }
    } catch (e) {
      return 'Network error: Unable to reach Groq server. Check internet connection.';
    }
  }
}