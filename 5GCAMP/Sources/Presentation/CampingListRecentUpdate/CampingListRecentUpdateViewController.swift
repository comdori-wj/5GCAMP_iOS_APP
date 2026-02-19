//
//  CampingListRecentUpdateViewController.swift
//  5GCAMP
//
//  Created by WONJI HA on 11/12/24.
//

import UIKit
import WebKit
import CoreLocation

final class CampingListRecentUpdateViewController: UIViewController, WebViewConfigurable {
    @IBOutlet weak var webView: WKWebView!
    var locationManager: CLLocationManager!
    private let campingListRecentUpdateViewModel = CampingListRecentUpdateViewModel()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        campingListRecentUpdateViewModel.loadWebView()
        print("업데이트순 뷰 진입")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpBindings()
        setUpWebView()
        setUpLocationManager()
    }
    
    private func setUpBindings() {
        campingListRecentUpdateViewModel.webViewRequest.bind { [weak self] request in
            if let request = request {
                self?.webView.load(request)
            }
        }
        
        campingListRecentUpdateViewModel.errorMessage.bind { [weak self] message in
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
}

extension CampingListRecentUpdateViewController: WKUIDelegate {
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

extension CampingListRecentUpdateViewController: WKNavigationDelegate {
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
}
