import SwiftUI

struct IncidentDetailView: View {
    let log: AuditLog
    @ObservedObject var lang = LanguageManager.shared // Dil eklendi
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // --- ÜST BİLGİ KARTI ---
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "person.crop.square.fill")
                            Text("\(localized("KULLANICI", "USER")): \(log.userId)")
                                .font(.headline)
                            Spacer()
                            Text(log.timestamp.prefix(16))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .foregroundColor(.green)
                        
                        Divider().background(Color.green.opacity(0.3))
                        
                        HStack {
                            Text(localized("DURUM:", "STATUS:"))
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(log.isSecure ? localized("BLOCKED (GÜVENLİ)", "BLOCKED (SECURE)") : localized("PASS (SIZINTI)", "PASS (LEAK)"))
                                .font(.caption)
                                .bold()
                                .foregroundColor(log.isSecure ? .red : .gray)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.darkGray).opacity(0.3))
                    .cornerRadius(10)
                    
                    // --- YAKALANAN ETİKETLER ---
                    if !log.detectedEntities.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(localized("TESPİT EDİLEN TEHDİTLER", "DETECTED THREATS"))
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            HStack {
                                ForEach(log.detectedEntities, id: \.self) { entity in
                                    Text(entity)
                                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color.red.opacity(0.2))
                                        .foregroundColor(.red)
                                        .cornerRadius(5)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 5)
                                                .stroke(Color.red.opacity(0.5), lineWidth: 1)
                                        )
                                }
                            }
                        }
                    }
                    
                    // --- ORİJİNAL METİN ---
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Image(systemName: "exclamationmark.shield.fill")
                                .foregroundColor(.red)
                            Text(localized("ORİJİNAL PROMPT (SIZINTI)", "ORIGINAL PROMPT (LEAK)"))
                                .font(.caption)
                                .foregroundColor(.red)
                                .bold()
                        }
                        
                        Text(log.originalPrompt)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.red.opacity(0.3), lineWidth: 1))
                    }
                    
                    // --- SANSÜRLÜ METİN ---
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Image(systemName: "checkmark.shield.fill")
                                .foregroundColor(.green)
                            Text(localized("SANSÜRLÜ PROMPT (LLM'E GİDEN)", "SANITIZED PROMPT (TO LLM)"))
                                .font(.caption)
                                .foregroundColor(.green)
                                .bold()
                        }
                        
                        Text(log.sanitizedPrompt)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.green)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.green.opacity(0.05))
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.green.opacity(0.3), lineWidth: 1))
                    }
                    
                    // --- KRİZ YÖNETİM BUTONLARI ---
                    VStack(spacing: 15) {
                        Divider().background(Color.gray.opacity(0.5)).padding(.vertical, 10)
                        
                        Text(localized("YÖNETİCİ AKSİYONU", "ADMIN ACTION"))
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 20) {
                            Button(action: { takeAction(action: "BLOCKED") }) {
                                HStack {
                                    Image(systemName: "hand.raised.fill")
                                    Text(localized("ENGELLE", "BLOCK"))
                                        .fontWeight(.bold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            
                            Button(action: { takeAction(action: "APPROVED") }) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text(localized("İZİN VER", "APPROVE"))
                                        .fontWeight(.bold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.top, 10)
                }
                .padding()
            }
        }
        .navigationTitle(localized("Olay Raporu", "Incident Report"))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func takeAction(action: String) {
        Task {
            do {
                try await NetworkManager.shared.updateLogAction(logId: log.id, action: action)
            } catch {
                print("Hata: \(error)")
            }
        }
    }
}
