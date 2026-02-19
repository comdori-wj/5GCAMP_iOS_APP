//
//  HomeViewController.swift
//  5GCAMP
//
//  Created by WONJI HA on 11/4/24.
//

import UIKit
import WebKit
import CoreLocation

final class HomeViewController: UIViewController, WebViewConfigurable {
    @IBOutlet weak var webView: WKWebView!
    var locationManager: CLLocationManager!
    private let homeViewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpWebView()
        setUpBindings()
        setUpLocationManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        homeViewModel.loadWebView()
        print("홈화면 새로고침 됨.")
    }
    
    private func setUpBindings() {
        homeViewModel.webViewRequest.bind { [weak self] request in
            if let request = request {
                self?.webView.load(request)
            }
        }
        
        homeViewModel.errorMessage.bind { [weak self] message in
            if let message = message {
                self?.errorAlert(message: message)
            }
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "locationHandler" {
            locationManager.requestLocation()
        }
        
        if message.name == "logoutNotification" {
            handleLogout()
        }
    }
    
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
        default:
            print("Allowing navigation for other schemes")
            decisionHandler(.allow)
        }
        
        if navigationAction.navigationType == .other {
            checkLocationAuthorization()
        }
        
    }
    
    private func logWebViewStatus(status: String) {
        print("\(String(describing: type(of: self))) 웹뷰 상태:", status)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        logWebViewStatus(status: "로딩 시작")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        logWebViewStatus(status: "로딩 완료")
        
        let script = """
        (function() {
            // 배너 데이터 확인 (이미 페이지에 있는 popupData 배열 사용)
            if (typeof popupData !== 'undefined' && popupData.length > 0) {
                // 오프캔버스 바디에 클릭 이벤트 추가
                var bannerBody = document.querySelector('#offcanvasBottom .offcanvas-body');
                if (bannerBody) {
                    bannerBody.style.cursor = 'pointer';
                    bannerBody.onclick = function() {
                        // 현재 표시된 배너 이미지 확인
                        var currentBannerImg = bannerBody.querySelector('img');
                        if (currentBannerImg && currentBannerImg.src) {
                            // 현재 표시된 이미지 URL에 해당하는 배너 데이터 찾기
                            for (var i = 0; i < popupData.length; i++) {
                                if (currentBannerImg.src.includes(popupData[i].image) || 
                                    popupData[i].image.includes(currentBannerImg.src)) {
                                    // 해당 배너의 링크로 이동
                                    window.location.href = popupData[i].link;
                                    return;
                                }
                            }
                        }
                        
                        // 일치하는 배너를 찾지 못한 경우 첫 번째 배너 링크로 이동 (폴백)
                        window.location.href = popupData[0].link;
                    };
                }
            }
        })();
        """

        webView.evaluateJavaScript(script, completionHandler: { result, error in
            if let error = error {
                print("JavaScript 실행 오류:", error.localizedDescription)
            } else {
                print("JavaScript 실행 성공")
            }
        })
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        logWebViewStatus(status: "로딩 실패 이유: \(error.localizedDescription)")
        
        // NSURLErrorDomain 오류 체크
        let nsError = error as NSError
        
        if nsError.domain == NSURLErrorDomain {
            let alertController = UIAlertController(
                title: "오지캠핑 서버 연결 오류",
                message: "서버에 문제가 발생하였습니다. 추후 다시 접속해 주시기를 바랍니다.",
                preferredStyle: .alert
            )
            
            let okAction = UIAlertAction(title: "확인", style: .default) { _ in
                // 앱 종료 처리
                UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    exit(0)
                }
            }
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true)
        }
    }
}

extension HomeViewController: WKUIDelegate {
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

extension HomeViewController: TabBarProtocol {
    func reloadView() {
        homeViewModel.loadWebView()
        print("홈뷰 리로드됨.")
    }
}
