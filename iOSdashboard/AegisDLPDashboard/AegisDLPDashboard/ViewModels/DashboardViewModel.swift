import Foundation

@MainActor
class DashboardViewModel: ObservableObject {
    // Arayüze bağlanacak gerçek log listemiz
    @Published var logs: [AuditLog] = []
    
    // Backend'den verileri çeken fonksiyon
    func loadLogs() async {
        do {
            self.logs = try await NetworkManager.shared.fetchLogs()
            print("Loglar başarıyla çekildi: \(self.logs.count) adet")
        } catch {
            print("LOG ÇEKME HATASI: \(error)")
        }
    }
}
