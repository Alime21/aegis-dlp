import SwiftUI

struct DashboardView: View {
    // 1. GERÇEK VERİ BAĞLANTISI BURADA BAŞLIYOR
    @StateObject private var viewModel = DashboardViewModel()
    @ObservedObject var lang = LanguageManager.shared // DİL YÖNETİCİSİ EKLENDİ
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {
                        
                        // --- 1. ÜST KISIM: DİNAMİK ÖZET KARTLARI ---
                        Text(localized("SİSTEM ÖZETİ", "SYSTEM SUMMARY"))
                            .font(.headline)
                            .foregroundColor(.green)
                            .tracking(2)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: columns, spacing: 15) {
                            // Değerleri viewModel.logs üzerinden dinamik hesaplıyoruz!
                            SummaryCard(title: localized("TARANAN PROMPT", "SCANNED PROMPTS"), value: "\(viewModel.logs.count)", icon: "cpu", color: .blue)
                            SummaryCard(title: localized("AKTİF TEHDİTLER", "ACTIVE THREATS"), value: "\(viewModel.logs.filter { !$0.detectedEntities.isEmpty }.count)", icon: "exclamationmark.triangle.fill", color: .red)
                            SummaryCard(title: localized("GÜVENLİ SIZINTI", "SECURED LEAKS"), value: "\(viewModel.logs.filter { $0.isSecure }.count)", icon: "shield.checkerboard", color: .green)
                            SummaryCard(title: localized("SİSTEM DURUMU", "SYSTEM STATUS"), value: localized("STABİL", "STABLE"), icon: "server.rack", color: .green)
                        }
                        .padding(.horizontal)
                        
                        Divider().background(Color.green.opacity(0.3)).padding(.vertical)
                        
                        // --- 2. ALT KISIM: SON İHLALLER LİSTESİ ---
                        HStack {
                            Text(localized("SON GÜVENLİK İHLALLERİ", "RECENT SECURITY BREACHES"))
                                .font(.headline)
                                .foregroundColor(.green)
                                .tracking(2)
                            
                            Spacer()
                            
                            // Sayfayı manuel yenilemek için küçük bir buton
                            Button(action: { Task { await viewModel.loadLogs() } }) {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(.green)
                            }
                        }
                        .padding(.horizontal)
                        
                        if viewModel.logs.isEmpty {
                            Text(localized("Ağdan veriler çekiliyor veya henüz log yok...", "Fetching data from network or no logs yet..."))
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            VStack(spacing: 12) {
                                // GERÇEK VERİLERİ (En yeniler üstte olacak şekilde) EKRANA BASIYORUZ
                                ForEach(viewModel.logs.reversed()) { log in
                                    NavigationLink(destination: IncidentDetailView(log: log)) {
                                        IncidentRow(log: log)
                                    }
                                    // Apple'ın standart mavi tıklama rengini eziyoruz ki tasarımımız bozulmasın
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                }
            }
            .navigationBarHidden(true)
            // SAYFA AÇILDIĞINDA OTOMATİK VERİ ÇEK
            .task {
                await viewModel.loadLogs()
            }
        }
    }
}

// Ozet Kartı Alt Bileşeni
struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            .font(.title2)
            
            Text(value)
                .font(.title)
                .bold()
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(UIColor.darkGray).opacity(0.3))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.5), lineWidth: 1)
        )
    }
}

// Liste Satırı Alt Bileşeni
struct IncidentRow: View {
    let log: AuditLog
    @ObservedObject var lang = LanguageManager.shared // Satırların da dilden haberdar olması için
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(log.userId)
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.white)
                
                // Backend'den gelen etiket dizisini arasına virgül koyarak yazdırıyoruz
                let noneText = localized("Yok", "None")
                let entities = log.detectedEntities.isEmpty ? noneText : log.detectedEntities.joined(separator: ", ")
                Text("\(localized("Tespit", "Detected")): \(entities)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 5) {
                // Sadece saati (örneğin 14:05) alacak küçük bir formatlama
                Text(String(log.timestamp.prefix(16).suffix(5)))
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(log.isSecure ? localized("BLOCKED", "BLOCKED") : localized("PASS", "PASS"))
                    .font(.caption2)
                    .bold()
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(log.isSecure ? Color.red.opacity(0.2) : Color.gray.opacity(0.2))
                    .foregroundColor(log.isSecure ? .red : .gray)
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(Color(UIColor.darkGray).opacity(0.2))
        .cornerRadius(8)
    }
}
