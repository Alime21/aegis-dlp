import SwiftUI

struct MainTabView: View {
    @ObservedObject var lang = LanguageManager.shared
    
    var body: some View {
        TabView {
            // 1. Sekme: yeşil terminal ekranı (ContentView)
            ContentView()
                .tabItem {
                    Label(localized("Terminal", "Terminal"), systemImage: "terminal.fill")
                }
            
            // 2. Sekme: Monitoring (DashboardView)
            DashboardView()
                .tabItem {
                    Label(localized("İzleme", "Monitoring"), systemImage: "chart.bar.xaxis")
                }
            // 3. SEKME: YENİ EKLEDİĞİMİZ POLİTİKALAR EKRENI
            PoliciesView()
                .tabItem {
                    Label(localized("Kurallar", "Policies"), systemImage: "lock.shield.fill")
                            }
        }
        .accentColor(.green)
    }
}
