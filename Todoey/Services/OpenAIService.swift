import Foundation

class OpenAIService {
    private let apiKey: String
    private let endpoint = "https://api.openai.com/v1/chat/completions"
    
    init() {
        // Get API key from configuration
        guard let key = APIKeys.getKey(for: "openAI") else {
            fatalError("OpenAI API key not found in configuration")
        }
        self.apiKey = key
    }
    
    func generateInspiringOptions(text: String) async throws -> [String] {
        let prompt = """
            Transform this todo item into 3 different inspiring versions (keep each version under 5 words, separate with '|'):
            Original: \(text)
            3 Inspiring versions:
            """
        
        let messages = [
            ["role": "system", "content": "You are a motivational assistant. Provide exactly 3 brief inspiring versions of tasks, separated by '|' characters. Keep each version under 5 words."],
            ["role": "user", "content": prompt]
        ]
        
        let parameters: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": messages,
            "max_tokens": 100,
            "temperature": 0.7
        ]
        
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        
        let options = response.choices.first?.message.content
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: "|")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } ?? []
        
        return options.count == 3 ? options : [text]
    }
}

// Response models
struct OpenAIResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
}

struct Message: Codable {
    let content: String
} 
