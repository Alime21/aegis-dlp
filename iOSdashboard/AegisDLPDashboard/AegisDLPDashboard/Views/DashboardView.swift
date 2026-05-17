import SwiftUI

// Şimdilik arayüzü test etmek için sahte (Mock) log modeli
struct IncidentLog: Identifiable {
    let id = UUID()
    let timestamp: String
    let user: String
    let detectedEntities: String
    let status: String
}

struct DashboardView: View {
    // Arayüzde göstereceğimiz sahte veriler (İleride bunu veritabanından çekeceğiz)
    let recentLogs = [
        IncidentLog(timestamp: "14:05", user: "emp_4521", detectedEntities: "CREDIT_CARD", status: "BLOCKED"),
        IncidentLog(timestamp: "13:42", user: "emp_1099", detectedEntities: "PASSWORD, PERSON", status: "BLOCKED"),
        IncidentLog(timestamp: "11:20", user: "emp_8832", detectedEntities: "LOCATION", status: "BLOCKED")
    ]
    
    // Grid (Izgara) sütun ayarı
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Senin tasarımına uygun koyu arka plan
                Color.black.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {
                        
                        // 1. ÜST KISIM: ÖZET KARTLARI
                        Text("SİSTEM ÖZETİ")
                            .font(.headline)
                            .foregroundColor(.green)
                            .tracking(2)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: columns, spacing: 15) {
                            SummaryCard(title: "ENGELLENEN SIZINTI", value: "1,284", icon: "shield.checkerboard", color: .green)
                            SummaryCard(title: "AKTİF TEHDİTLER", value: "3", icon: "exclamationmark.triangle.fill", color: .red)
                            SummaryCard(title: "TARANAN PROMPT", value: "45.2K", icon: "cpu", color: .blue)
                            SummaryCard(title: "SİSTEM DURUMU", value: "STABİL", icon: "server.rack", color: .green)
                        }
                        .padding(.horizontal)
                        
                        Divider().background(Color.green.opacity(0.3)).padding(.vertical)
                        
                        // 2. ALT KISIM: SON İHLALLER LİSTESİ
                        Text("SON GÜVENLİK İHLALLERİ")
                            .font(.headline)
                            .foregroundColor(.green)
                            .tracking(2)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            ForEach(recentLogs) { log in
                                IncidentRow(log: log)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// Ozet Kartı Alt Bileşeni (Sub-View)
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

// Liste Satırı Alt Bileşeni (Sub-View)
struct IncidentRow: View {
    let log: IncidentLog
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(log.user)
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.white)
                Text("Tespit: \(log.detectedEntities)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 5) {
                Text(log.timestamp)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(log.status)
                    .font(.caption2)
                    .bold()
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.2))
                    .foregroundColor(.red)
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(Color(UIColor.darkGray).opacity(0.2))
        .cornerRadius(8)
    }
}

#Preview {
    DashboardView()
}

