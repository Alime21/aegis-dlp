import Foundation

// API'ye göndereceğimiz veri yapısı
struct PromptRequest: Codable {
    let user_id: String
    let prompt: String
}

// API'den bize dönecek olan nihai veri yapısı
struct PromptResponse: Codable {
    let llm_response: String
    let status: String
}
