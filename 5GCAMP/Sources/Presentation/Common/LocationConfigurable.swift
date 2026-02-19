//
//  LocationConfigurable.swift
//  5GCAMP
//
//  Created by WONJI HA on 11/11/24.
//

import UIKit
import WebKit
import CoreLocation

protocol LocationConfigurable: AnyObject, CLLocationManagerDelegate {
    var webView: WKWebView! { get set }
    var locationManager: CLLocationManager! { get set }
    func setUpLocationManager()
}

extension LocationConfigurable where Self: UIViewController, Self: CLLocationManagerDelegate {
    func setUpLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            showRequestLocationServiceAlert()
            print("설정으로 가서 위치권한 유도 하기.")
        case .authorizedAlways:
            print("always")
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let script = "updateLocation(\(location.coordinate.latitude), \(location.coordinate.longitude));"
            webView?.evaluateJavaScript(script)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func showRequestLocationServiceAlert() {
        let requestLocationServiceAlert = UIAlertController(title: "현재 위치 정보 이용 안내", message: "위치 서비스를 사용할 수 없습니다.\n디바이스의 '설정 → 개인정보 보호 및 보안 '에서 위치 서비스를 항상으로 켜주세요.", preferredStyle: .alert)
        let goSetting = UIAlertAction(title: "설정으로 이동", style: .destructive) { _ in
            if let appSetting = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSetting)
            }
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel) { _ in }
        requestLocationServiceAlert.addAction(cancel)
        requestLocationServiceAlert.addAction(goSetting)
        
        present(requestLocationServiceAlert, animated: true)
    }
}
