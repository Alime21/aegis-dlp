import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @State private var inputPrompt: String = ""
    
    var body: some View {
        ZStack {
            // Arka planı tamamen siyah yapıyoruz
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 25) {
                
                // --- ÜST BAŞLIK ---
                HStack(spacing: 10) {
                    Image(systemName: "shield.checkerboard") // Siber güvenlik ikonu
                        .font(.title2)
                        .foregroundColor(.green)
                    
                    Text("AEGIS-DLP TERMINAL")
                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                        .foregroundColor(.green)
                        .shadow(color: .green.opacity(0.6), radius: 5, x: 0, y: 0) // Neon parlaması
                }
                .padding(.top, 20)
                
                // --- İNPUT ALANI ---
                TextField(">> LLM_prompt_giriniz...", text: $inputPrompt)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.green)
                    .padding()
                    .background(Color.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.green.opacity(0.6), lineWidth: 1.5)
                    )
                    .padding(.horizontal)
                    .colorScheme(.dark) // Klavyenin koyu tema çıkması için
                
                // --- GÜVENLİ GÖNDER BUTONU ---
                Button(action: {
                    // İnternet işlemini bir Task içine alıp başına await ekliyoruz
                    Task {
                        await viewModel.executeChat(prompt: inputPrompt)
                        inputPrompt = "" // Mesaj gittikten sonra kutuyu temizler
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(5)
                    } else {
                        HStack {
                            Image(systemName: "lock.shield.fill")
                            Text("GÜVENLİ GÖNDER")
                                .bold()
                        }
                        .font(.system(.headline, design: .monospaced))
                        .foregroundColor(.black) // Siyah metin
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green) // Yeşil arka plan
                        .cornerRadius(5)
                        .shadow(color: .green.opacity(0.5), radius: 8, x: 0, y: 0)
                    }
                }
                .padding(.horizontal)
                
                // --- TERMİNAL ÇIKTI EKRANI ---
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("DLP_STATUS:")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.gray)
                        
                        Text(viewModel.statusMessage.isEmpty ? "[ STANDBY ]" : "[ \(viewModel.statusMessage.uppercased()) ]")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.green)
                            .bold()
                    }
                    
                    Divider()
                        .background(Color.green.opacity(0.3))
                    
                    Text("LLM_RESPONSE:")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.gray)
                    
                    ScrollView {
                        Text(viewModel.llmResponse.isEmpty ? "Awaiting input..." : viewModel.llmResponse)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.green)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 250) // Terminal penceresine sabit bir yükseklik verelim
                .background(Color.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.green.opacity(0.4), lineWidth: 1)
                )
                .padding(.horizontal)
                
                Spacer()
            }
        }
    }
}

#Preview {
    ContentView()
}
