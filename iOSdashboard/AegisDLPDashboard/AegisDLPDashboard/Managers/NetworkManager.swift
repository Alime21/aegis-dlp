import Foundation

enum NetworkError: Error {
    case invalidURL
    case serializationError
    case badResponse
}

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    // Mac simülatörü çalıştığı için localhost (127.0.0.1) adresine doğrudan erişebilir
    private let baseURL = "http://127.0.0.1:8000"
    
    func sendPrompt(userId: String, prompt: String) async throws -> PromptResponse {
        guard let url = URL(string: "\(baseURL)/chat") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Veriyi JSON formatına çeviriyoruz
        let requestBody = PromptRequest(user_id: userId, prompt: prompt)
        guard let jsonData = try? JSONEncoder().encode(requestBody) else {
            throw NetworkError.serializationError
        }
        request.httpBody = jsonData
        
        // Asenkron olarak isteği atıyoruz
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.badResponse
        }
        
        // Gelen JSON yanıtını Swift nesnesine çözümlüyoruz
        let decodedResponse = try JSONDecoder().decode(PromptResponse.self, from: data)
        return decodedResponse
    }
    // --- LOGLARI ÇEKME FONKSİYONU ---
        func fetchLogs() async throws -> [AuditLog] {
            // Backend API'mizin log ucu
            guard let url = URL(string: "http://127.0.0.1:8000/logs") else {
                throw URLError(.badURL)
            }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // Gelen JSON verisini AuditLog dizisine çeviriyoruz
            let logs = try JSONDecoder().decode([AuditLog].self, from: data)
            return logs
        }
    
    // --- 1. Policies SUNUCUDAN ÇEK ---
        func fetchPolicies() async throws -> PolicyConfig {
            guard let url = URL(string: "\(baseURL)/policies") else { throw NetworkError.invalidURL }
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode(PolicyConfig.self, from: data)
        }
        
    // --- 2. Policies SUNUCUDA GÜNCELLE ---
        func updatePolicies(config: PolicyConfig) async throws {
            guard let url = URL(string: "\(baseURL)/policies") else { throw NetworkError.invalidURL }
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(config)
            
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw NetworkError.badResponse
            }
        }
    
    // --- 3. LOG İÇİN AKSİYON AL (ONAYLA / ENGELLE) ---
        func updateLogAction(logId: Int, action: String) async throws {
            guard let url = URL(string: "\(baseURL)/logs/\(logId)/action") else { throw NetworkError.invalidURL }
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Gönderilecek JSON paketini hazırlıyoruz: {"action": "APPROVED"}
            let body = ["action": action]
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw NetworkError.badResponse
            }
        }
    
    // --- 4. SİSTEM DURUMUNU (KILL SWITCH) ÇEK VE GÜNCELLE ---
        func fetchSystemStatus() async throws -> Bool {
            guard let url = URL(string: "\(baseURL)/system/status") else { throw NetworkError.invalidURL }
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode([String: Bool].self, from: data)
            return response["is_active"] ?? true
        }
        
        func updateSystemStatus(isActive: Bool) async throws {
            guard let url = URL(string: "\(baseURL)/system/status") else { throw NetworkError.invalidURL }
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body = ["is_active": isActive]
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw NetworkError.badResponse
            }
        }
}
