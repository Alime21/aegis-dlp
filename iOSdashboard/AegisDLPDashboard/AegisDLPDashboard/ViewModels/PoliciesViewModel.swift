import Foundation

@MainActor
class PoliciesViewModel: ObservableObject {
    @Published var config = PolicyConfig(credit_card: true, password: true, tckn: true)
    @Published var isSystemActive = true
    @Published var isLoading = false
    
    // Sayfa açıldığında mevcut ayarları API'den yükle
    func loadPolicies() async {
        do {
            self.config = try await NetworkManager.shared.fetchPolicies()
            self.isSystemActive = try await NetworkManager.shared.fetchSystemStatus()
        } catch {
            print("Kurallar yüklenemedi: \(error)")
        }
    }
    
    // Toggle değiştiğinde API'ye PUT isteği at
    func savePolicies() {
        self.isLoading = true
        Task {
            do {
                try await NetworkManager.shared.updatePolicies(config: self.config)
                print("Kurallar başarıyla sunucuda güncellendi.")
            } catch {
                print("Kural güncelleme hatası: \(error)")
            }
            self.isLoading = false
        }
    }
    
    func toggleKillSwitch() {
            self.isSystemActive.toggle()
            Task {
                do {
                    try await NetworkManager.shared.updateSystemStatus(isActive: self.isSystemActive)
                } catch {
                    print("❌ Kill Switch hatası: \(error)")
                    self.isSystemActive.toggle() // Hata olursa butonu geri al
                }
            }
        }
}
