//
//  AegisDLPDashboardApp.swift
//  AegisDLPDashboard
//
//  Created by Macbook on 17.05.2026.
//

import SwiftUI

@main
struct AegisDLPDashboardApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.dark)
        }
    }
}
