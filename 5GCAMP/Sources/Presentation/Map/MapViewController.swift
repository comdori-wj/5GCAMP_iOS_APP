//
//  MapViewController.swift
//  5GCAMP
//
//  Created by WONJI HA on 11/13/24.
//

import UIKit
import WebKit
import CoreLocation

final class MapViewController: UIViewController, WebViewConfigurable, LocationConfigurable {
    @IBOutlet weak var webView: WKWebView!
    var locationManager: CLLocationManager!
    private let mapViewModel = MapViewModel()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapViewModel.loadWebView()
        print("맵 뷰 진입")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        setUpWebView()
        setUpLocationManager()
    }
    
    private func setupBindings() {
        mapViewModel.webViewRequest.bind { [weak self] request in
            if let request = request {
                self?.webView.load(request)
            }
        }
        
        mapViewModel.errorMessage.bind { [weak self] message in
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

extension MapViewController: WKNavigationDelegate {
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
        
        if navigationAction.navigationType == .other {
            checkLocationAuthorization()
        }
    }
}

extension MapViewController: TabBarProtocol {
    func reloadView() {
        mapViewModel.loadWebView()
        print("맵 리로드됨.")
    }
}
