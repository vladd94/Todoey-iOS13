// Rename this file to APIKeys.swift and add your actual API keys
struct APIKeys_template {
    static let keys: [String: String] = [
        "openAI": "YOUR_OPENAI_API_KEY_HERE"
        // Add other API keys as needed
    ]
    
    static func getKey(for service: String) -> String? {
        return keys[service]
    }
} 
