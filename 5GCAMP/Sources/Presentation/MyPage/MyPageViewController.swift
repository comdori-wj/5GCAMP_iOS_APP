//
//  MyPageViewController.swift
//  5GCAMP
//
//  Created by WONJI HA on 11/14/24.
//

import UIKit
import WebKit
import CoreLocation

final class MyPageViewController: UIViewController, WebViewConfigurable {
    @IBOutlet weak var webView: WKWebView!
    var locationManager: CLLocationManager!
    private let mypageViewModel = MyPageViewModel()
    private var isCheckingLogin = false  // 로그인 체크 중복 방지 플래그
    private var hasShownLoginView = false  // 로그인 뷰 표시 여부 플래그
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkLoginStatusAndLoadWebView()
        print("마이페이지 뷰 진입")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        setUpWebView()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadAfterLogin), name: NSNotification.Name("LoginSuccessful"), object: nil)
    }
    
    private func setupBindings() {
        mypageViewModel.webViewRequest.bind { [weak self] request in
            if let request = request {
                self?.webView.load(request)
            }
        }
        
        mypageViewModel.errorMessage.bind { [weak self] message in
            if let message = message {
                self?.errorAlert(message: message)
            }
        }
    }
    
    private func checkLoginStatusAndLoadWebView() {
        guard !isCheckingLogin else { return }
        isCheckingLogin = true
        guard let checkLoginURLRequest = mypageViewModel.loginCheckURLLoad() else {
            moveToLoginView()
            return
        }
        
        let task = URLSession.shared.dataTask(with: checkLoginURLRequest) { [weak self] (data, response, error) in
            guard let self = self else { return }
            defer { self.isCheckingLogin = false }
            
            if let error = error {
                print("로그인 상태 확인 오류:", error.localizedDescription)
                self.moveToLoginView()
                return
            }
            
            guard let data = data else {
                self.moveToLoginView()
                return
            }
            
            // 서버 응답 로깅
            if let responseString = String(data: data, encoding: .utf8) {
                print("마이페이지 로그인 서버 응답:", responseString)
                
                // HTML 응답인지 확인
                if responseString.contains("<!DOCTYPE html") {
                    // 세션 쿠키 확인으로 로그인 상태 판단
                    if let cookies = HTTPCookieStorage.shared.cookies,
                       cookies.contains(where: { $0.name == "PHPSESSID" }) {
                        DispatchQueue.main.async {
                            self.mypageViewModel.loadWebView()
                        }
                        return
                    } else {
                        self.moveToLoginView()
                        return
                    }
                }
                
                // JSON 파싱 시도
                do {
                    let decoder = JSONDecoder()
                    let loginStatus = try decoder.decode(LoginModel.self, from: data)
                    DispatchQueue.main.async {
                        if loginStatus.status {
                            self.mypageViewModel.loadWebView()
                        } else {
                            self.moveToLoginView()
                        }
                    }
                } catch {
                    print("JSON Decoding Error:", error.localizedDescription)
                    
                    // JSON 파싱 실패 시 문자열에서 status 확인
                    if responseString.contains("\"status\":true") {
                        DispatchQueue.main.async {
                            self.mypageViewModel.loadWebView()
                        }
                    } else {
                        self.moveToLoginView()
                    }
                }
            } else {
                self.moveToLoginView()
            }
        }
        task.resume()
    }
    
    private func moveToLoginView() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard self.presentedViewController == nil else { return }
            let storyBoard = UIStoryboard(name: "Login", bundle: nil)
            if let loginViewController = storyBoard.instantiateViewController(withIdentifier: "LoginView") as? LoginViewController {
                loginViewController.modalPresentationStyle = .overFullScreen
                self.present(loginViewController, animated: true)
            }
        }
    }
    
    @objc private func reloadAfterLogin() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.checkLoginStatusAndLoadWebView()
            self.reloadWebViewWithDelay()
        }
    }
    
    func reloadWebViewWithDelay() {
        // 마이페이지 웹뷰 강제 리로드 (지연시간 추가)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            if let mypageRequest = self?.mypageViewModel.loadWebView() {
                self?.webView.load(mypageRequest)
                print("마이페이지 웹뷰 강제 리로드")
            }
        }
    }

    
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "logoutNotification" {
            handleLogout()
            moveToLoginView()
        }
    }
}


extension MyPageViewController: WKUIDelegate {
    private func presentAlert(title: String? = nil, message: String, actions: [UIAlertAction], textField: ((UITextField) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let configureTextField = textField {
            alertController.addTextField(configurationHandler: configureTextField)
        }
        actions.forEach { alertController.addAction($0) }
        present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let action = UIAlertAction(title: "확인", style: .default) { _ in completionHandler() }
        presentAlert(message: message, actions: [action])
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping @MainActor (Bool) -> Void) {
        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in completionHandler(true) }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in completionHandler(false) }
        presentAlert(message: message, actions: [confirmAction, cancelAction])
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping @MainActor (String?) -> Void) {
        let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            let text = self?.getAlertText(defaultText: defaultText)
            completionHandler(text)
        }
        presentAlert(message: prompt, actions: [confirmAction]) { textField in
            textField.text = defaultText
        }
    }
    
    
    private func getAlertText(defaultText: String?) -> String? {
        guard let alertController = presentedViewController as? UIAlertController,
              let textField = alertController.textFields?.first else {
            return defaultText
        }
        return textField.text?.isEmpty == false ? textField.text : defaultText
    }
}

extension MyPageViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url, let scheme = url.scheme else {
            print("Allowing navigation (no URL or scheme)")
            decisionHandler(.allow)
            return
        }
        
        print("Navigating to: \(url.absoluteString)")
        print("Scheme: \(scheme)")
        
        switch scheme {
        case "tel":
            handleTelURL(url: url)
            decisionHandler(.cancel)
        case "http", "https":
            handleWebURL(url: url, decisionHandler: decisionHandler)
        case "app":
            handleAppURL(url: url, webView: webView, decisionHandler: decisionHandler)
        default:
            print("Allowing navigation for other schemes")
            decisionHandler(.allow)
        }
    }
}

extension MyPageViewController: TabBarProtocol {
    func reloadView() {
        hasShownLoginView = false
        checkLoginStatusAndLoadWebView()
        print("마이페이지 리로드됨.")
    }
}
