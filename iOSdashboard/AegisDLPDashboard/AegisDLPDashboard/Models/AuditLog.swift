import Foundation

struct AuditLog: Identifiable, Codable {
    let id: Int
    let timestamp: String
    let userId: String
    let isSecure: Bool
    let detectedEntities: [String]
    let originalPrompt: String
    let sanitizedPrompt: String

    enum CodingKeys: String, CodingKey {
        case id, timestamp
        case userId = "user_id"
        case isSecure = "is_secure"
        case detectedEntities = "detected_entities"
        case originalPrompt = "original_prompt"
        case sanitizedPrompt = "sanitized_prompt"
    }

    // --- ESNEK DECODER (Python Veri Uyuşmazlıklarını Önleyen Zırhlı Kısım) ---
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Standart String ve Int alanları normal çözüyoruz
        id = try container.decode(Int.self, forKey: .id)
        timestamp = try container.decode(String.self, forKey: .timestamp)
        userId = try container.decode(String.self, forKey: .userId)
        originalPrompt = try container.decode(String.self, forKey: .originalPrompt)
        sanitizedPrompt = try container.decode(String.self, forKey: .sanitizedPrompt)
        
        // 1. is_secure Kontrolü: İster Bool (true/false) gelsin, ister Int (1/0)
        if let boolValue = try? container.decode(Bool.self, forKey: .isSecure) {
            isSecure = boolValue
        } else if let intValue = try? container.decode(Int.self, forKey: .isSecure) {
            isSecure = intValue == 1
        } else {
            isSecure = false
        }
        
        // 2. detected_entities Kontrolü: İster gerçek [String] gelsin, ister düz metin
        if let arrayValue = try? container.decode([String].self, forKey: .detectedEntities) {
            detectedEntities = arrayValue
        } else if let stringValue = try? container.decode(String.self, forKey: .detectedEntities) {
            // Eğer veri "['CREDIT_CARD', 'PASSWORD']" gibi metin geldiyse temizle ve diziye çevir
            let cleaned = stringValue.replacingOccurrences(of: "[", with: "")
                                     .replacingOccurrences(of: "]", with: "")
                                     .replacingOccurrences(of: "'", with: "")
                                     .replacingOccurrences(of: "\"", with: "")
                                     .trimmingCharacters(in: .whitespacesAndNewlines)
            
            if cleaned.isEmpty {
                detectedEntities = []
            } else {
                detectedEntities = cleaned.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            }
        } else {
            detectedEntities = []
        }
    }
}
