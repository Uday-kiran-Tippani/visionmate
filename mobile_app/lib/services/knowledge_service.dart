import 'dart:convert';
import 'package:http/http.dart' as http;

class KnowledgeService {
  Future<String> queryWikipedia(String query) async {
    try {
      final url = Uri.parse(
          'https://en.wikipedia.org/w/api.php?action=query&format=json&prop=extracts&exintro=true&explaintext=true&titles=$query');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final pages = data['query']['pages'];
        if (pages == null) return "I couldn't find anything on that.";

        final pageId = pages.keys.first;
        if (pageId == "-1") return "I couldn't find anything on that.";

        final extract = pages[pageId]['extract'];
        // Truncate for brevity
        if (extract.length > 200) {
          return extract.substring(0, 200) + "...";
        }
        return extract;
      } else {
        return "I'm having trouble connecting to my knowledge base.";
      }
    } catch (e) {
      return "I'm having trouble connection to the internet.";
    }
  }
}
