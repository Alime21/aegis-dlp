import Foundation
import SwiftUI

// Uygulamanın her yerinden erişilebilecek global dil yöneticisi
class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    // true ise İngilizce, false ise Türkçe
    @Published var isEnglish: Bool = false
    
    // Çeviri fonksiyonu
    func t(tr: String, en: String) -> String {
        return isEnglish ? en : tr
    }
}

func localized(_ tr: String, _ en: String) -> String {
    return LanguageManager.shared.t(tr: tr, en: en)
}
