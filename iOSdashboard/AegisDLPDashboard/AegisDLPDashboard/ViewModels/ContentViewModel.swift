import Foundation

@MainActor
class ContentViewModel: ObservableObject {
    @Published var llmResponse: String = ""
    @Published var statusMessage: String = ""
    @Published var isLoading: Bool = false
    
    func executeChat(prompt: String) async {
        guard !prompt.isEmpty else { return }
        
        self.isLoading = true
        self.statusMessage = "Analysing..."
        
        do {
            // Backend'e gönderiyoruz
            let response = try await NetworkManager.shared.sendPrompt(userId: "emp_4521", prompt: prompt)
            
            // Backend'den gelen yanıtları modele işliyoruz
            self.llmResponse = response.llm_response
            self.statusMessage = "Secure"
        } catch {
            self.llmResponse = "Hata oluştu: \(error.localizedDescription)"
            self.statusMessage = "Error"
        }
        
        self.isLoading = false
    }
}
