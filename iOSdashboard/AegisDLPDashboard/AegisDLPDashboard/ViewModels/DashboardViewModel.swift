import Foundation

@MainActor // Arayüz güncellemelerinin ana tatta (Main Thread) yapılmasını garanti eder
class DashboardViewModel: ObservableObject {
    @Published var llmResponse: String = "Henüz bir istek atılmadı."
    @Published var isLoading: Bool = false
    @Published var statusMessage: String = ""
    
    func executeChat(prompt: String) {
        self.isLoading = true
        
        Task {
            do {
                // Mock olarak bir kullanıcı ID'si gönderiyoruz
                let result = try await NetworkManager.shared.sendPrompt(userId: "ciso_root", prompt: prompt)
                self.llmResponse = result.llm_response
                self.statusMessage = result.status
            } catch {
                self.llmResponse = "Hata oluştu: \(error.localizedDescription)"
            }
            self.isLoading = false
        }
    }
}
