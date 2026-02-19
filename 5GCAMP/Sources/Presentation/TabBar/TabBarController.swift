//
//  TabBarController.swift
//  5GCAMP
//
//  Created by WONJI HA on 11/6/24.
//

import UIKit
import WebKit
import CoreLocation

final class TabBarController: UITabBarController, UITabBarControllerDelegate, LocationConfigurable {
    var webView: WKWebView!
    var locationManager: CLLocationManager!
    var previousSelectedIndex: Int = 0 // 이전 선택된 탭의 인덱스
    var originalTabBarTitles: [String] = [] // 초기 탭 이름 저장 배열
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.selectedIndex = 2
        saveOriginalTabBarTitles()
        setUpLocationManager()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard NetworkManager.networkConnected() else {
            let alertController = UIAlertController(title: "네트워크 오류", message: "비행기모드 또는 WI-FI 또는 셀룰러 데이터가 연결되어 있지 않습니다. 연결을 확인 후 다시 접속해 주시기를 바랍니다.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
                UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    exit(0)
                }
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let selectedIndex = tabBarController.selectedIndex
        let tabBarItem = tabBarController.tabBar.items?[selectedIndex]
        
        // 다른 탭 선택시 원래의 탭이름 복원
        if let items = self.tabBar.items {
            for (index, item) in items.enumerated() {
                if index < originalTabBarTitles.count {
                    item.title = originalTabBarTitles[index]
                }
            }
        }
        
        // 이전에 선택된 탭의 인덱스를 저장하는 속성 추가
        if selectedIndex == self.previousSelectedIndex {
            // 같은 탭이 다시 선택되었을 때
            if let navigationController = viewController as? UINavigationController {
                // 네비게이션 컨트롤러인 경우
                if let topViewController = navigationController.topViewController as? TabBarProtocol {
                    topViewController.reloadView()
                }
            } else if let reloadableViewController = viewController as? TabBarProtocol {
                // 일반 뷰 컨트롤러인 경우
                reloadableViewController.reloadView()
            }
            print("현재 선택된 탭 번호: ", selectedIndex)
        }
        
        switch selectedIndex {
        case 3:
            tabBarItem?.title = "현위치"
        default:
            break
        }
        
        // 현재 선택된 인덱스를 이전 인덱스로 저장
        self.previousSelectedIndex = selectedIndex
        print("이전 선택된 인덱스 출력 : ",previousSelectedIndex)
    }
    
    func saveOriginalTabBarTitles() {
        if let items = self.tabBar.items {
            originalTabBarTitles = items.compactMap { $0.title }
        }
    }
}
