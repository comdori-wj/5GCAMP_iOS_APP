//
//  WebViewConfigurable.swift
//  5GCAMP
//
//  Created by WONJI HA on 11/11/24.
//

import Foundation
import WebKit

protocol WebViewConfigurable: AnyObject, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler, LocationConfigurable {
    var webView: WKWebView! { get set }
    func setUpWebView()
    func handleLogout()
}

extension WebViewConfigurable where Self: UIViewController {
    func setUpWebView() {
        let preferences = WKPreferences()
        let webConfiguration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        
        webConfiguration.userContentController = contentController
        contentController.add(self, name: "locationHandler")
        contentController.add(self, name: "logoutNotification")
        
        preferences.javaScriptCanOpenWindowsAutomatically = true
        
        webConfiguration.preferences = preferences
        webConfiguration.userContentController = contentController
        webConfiguration.websiteDataStore = WKWebsiteDataStore.default()
        
        webView.configuration.preferences = preferences
        webView.configuration.userContentController = contentController
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
    }
    
    func handleTelURL(url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        print("Opening tel URL externally")
    }
    
    func handleWebURL(url: URL, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if url.host?.contains(URLManager().mainDomain) == true {
            print("Allowing navigation for internal domain")
            decisionHandler(.allow)
        } else {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            print("Opening http/https URL externally")
            decisionHandler(.cancel)
        }
    }
    
    func handleAppURL(url: URL, webView: WKWebView, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.scheme = "https"
        components?.host = URLManager().mainDomain
        
        if let httpsURL = components?.url {
            print("Converting app:// to https:// - New URL: \(httpsURL.absoluteString)")
            let request = URLRequest(url: httpsURL)
            webView.load(request)
            decisionHandler(.cancel) // 현재 네비게이션을 취소하고 새 요청을 로드
        } else {
            print("Failed to convert app:// to https://")
            decisionHandler(.allow) // 변환에 실패한 경우 원래 요청을 허용
        }
    }
    
    
    func errorAlert(message: String) {
        let alertController = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func handleLogout() {
        // 웹뷰 쿠키 삭제
        WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
            cookies.forEach { cookie in
                WKWebsiteDataStore.default().httpCookieStore.delete(cookie)
            }
        }
        
        // 네이티브 앱 세션 데이터 삭제
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        UserDefaults.standard.removeObject(forKey: "userSession")
        UserDefaults.standard.synchronize()
    }
    
    func clearAllCookies(completion: @escaping () -> Void) {
        // HTTPCOOkiesStorage 쿠키 삭제
        if let cookies = HTTPCookieStorage.shared.cookies {
            cookies.forEach { cookie in
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
        WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
            let group = DispatchGroup()
            cookies.forEach { cookie in
                group.enter()
                WKWebsiteDataStore.default().httpCookieStore.delete(cookie) {
                    group.leave()
                }
            }
            group.notify(queue: .main) {
                completion()
            }
        }
    }
}
