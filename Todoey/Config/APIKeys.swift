struct APIKeys {
    static let keys: [String: String] = [
        "openAI": "ssk-proj-QbmryCWtMkdKg68PwWAQ_Yn6Hk359ZRyh95da0T58CF0wzIchLvlxJ6Es8qlo2qR_NiHmIxJndT3BlbkFJWqLplEgtalZhe8w166V9W-VmpYQWErgdYXP2AkiWCUunSXtWh8Pbk-JxRW0tp2-boLgqYSkiMA"
    ]
    
    static func getKey(for service: String) -> String? {
        return keys[service]
    }
} 
