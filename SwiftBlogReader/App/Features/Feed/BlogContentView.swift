import SwiftUI
import WebKit

struct BlogContentView: View {
    @State private var webPage = WebPage()
    let html: String
    let baseURL: URL

    var body: some View {
        WebView(webPage)
            .onChange(of: html) {
                webPage.load(html: html, baseURL: baseURL)
            }
            .onAppear {
                webPage.load(html: html, baseURL: baseURL)
            }
    }
}
