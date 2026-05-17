import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            // 1. Sekme: Senin o yeşil terminal ekranın (ContentView)
            ContentView()
                .tabItem {
                    Label("Terminal", systemImage: "terminal.fill")
                }
            
            // 2. Sekme: Yeni yaptığımız izleme ekranı (DashboardView)
            DashboardView()
                .tabItem {
                    Label("Monitoring", systemImage: "chart.bar.xaxis")
                }
        }
        .accentColor(.green)
    }
}
