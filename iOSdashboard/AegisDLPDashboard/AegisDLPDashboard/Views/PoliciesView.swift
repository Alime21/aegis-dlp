import SwiftUI

struct PoliciesView: View {
    @StateObject private var viewModel = PoliciesViewModel()
    @ObservedObject var lang = LanguageManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .leading, spacing: 25) {
                    
                    // BAŞLIK VE DİL BUTONU
                    HStack {
                        Text(localized("GÜVENLİK POLİTİKALARI", "SECURITY POLICIES"))
                            .font(.headline)
                            .foregroundColor(.green)
                            .tracking(2)
                        
                        Spacer()
                        
                        // 🌍 DİL DEĞİŞTİRME BUTONU
                        Button(action: {
                            lang.isEnglish.toggle()
                        }) {
                            HStack {
                                Image(systemName: "globe")
                                Text(lang.isEnglish ? "EN" : "TR")
                                    .fontWeight(.bold)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    Text(localized("Aktif veri sızıntısı koruma kalkanlarını buradan canlı olarak yönetebilirsiniz.", "Manage active data leak protection shields live from here."))
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    
                    // TOGGLE LİSTESİ
                    Form {
                        Section(header: Text(localized("AKTİF SANSÜR MOTORLARI", "ACTIVE CENSORSHIP ENGINES")).foregroundColor(.green)) {
                            
                            Toggle(isOn: $viewModel.config.credit_card) {
                                Label(localized("Kredi Kartı Koruması", "Credit Card Protection"), systemImage: "creditcard.and.123")
                            }
                            .onChange(of: viewModel.config.credit_card) { _ in viewModel.savePolicies() }
                            
                            Toggle(isOn: $viewModel.config.password) {
                                Label(localized("Şifre / Parola Koruması", "Password Protection"), systemImage: "key.fill")
                            }
                            .onChange(of: viewModel.config.password) { _ in viewModel.savePolicies() }
                            
                            Toggle(isOn: $viewModel.config.tckn) {
                                Label(localized("TCKN Koruması (Hassas Kimlik)", "National ID Protection"), systemImage: "doc.plaintext.fill")
                            }
                            .onChange(of: viewModel.config.tckn) { _ in viewModel.savePolicies() }
                        }
                        .listRowBackground(Color(UIColor.darkGray).opacity(0.2))
                        .foregroundColor(.white)
                    }
                    .background(Color.black)
                    .scrollContentBackground(.hidden) // Form arka planını temizlemek için
                    
                    // --- KILL SWITCH (ACİL DURUM ŞALTERİ) ---
                    VStack(spacing: 15) {
                        Divider().background(Color.gray.opacity(0.3)).padding(.horizontal)
                        
                        Text(localized("KRİZ YÖNETİMİ", "INCIDENT MANAGEMENT"))
                            .font(.caption)
                            .foregroundColor(.red)
                            .tracking(2)
                            .bold()
                        
                        Button(action: {
                            // Canlı bir sistemde burada "Emin misiniz?" pop-up'ı çıkarılır, şimdilik direkt tetikliyoruz
                            viewModel.toggleKillSwitch()
                        }) {
                            HStack {
                                Image(systemName: viewModel.isSystemActive ? "power" : "lock.shield.fill")
                                    .font(.title2)
                                Text(viewModel.isSystemActive ? localized("SİSTEMİ DURDUR", "HALT SYSTEM") : localized("SİSTEMİ YENİDEN BAŞLAT", "RESTART SYSTEM"))
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.isSystemActive ? Color.red.opacity(0.9) : Color.green.opacity(0.9))
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .shadow(color: viewModel.isSystemActive ? Color.red.opacity(0.5) : Color.green.opacity(0.5), radius: 10, x: 0, y: 5)
                        }
                        .padding(.horizontal)
                        
                        Text(viewModel.isSystemActive ? localized("Tüm LLM trafiğini anında keser.", "Instantly cuts off all LLM traffic.") : localized("Ağ trafiği şu an kapalı. Açmak için dokunun.", "Network traffic is currently closed. Tap to open."))
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 10)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .task {
                await viewModel.loadPolicies()
            }
        }
    }
}
