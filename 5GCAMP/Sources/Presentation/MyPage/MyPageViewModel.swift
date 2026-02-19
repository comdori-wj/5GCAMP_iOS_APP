//
//  MyPageViewModel.swift
//  5GCAMP
//
//  Created by WONJI HA on 11/18/24.
//

import Foundation

final class MyPageViewModel {
    private let urlManager: URLManager
    private(set) var webViewRequest: Observable<URLRequest?> = Observable(nil)
    private(set) var isLoading: Observable<Bool> = Observable(false)
    private(set) var errorMessage: Observable<String?> = Observable(nil)
    
    init(urlManager: URLManager = URLManager()) {
        self.urlManager = urlManager
    }
    
    func loadWebView() -> URLRequest? {
        isLoading.value = true
        if let request = urlManager.mypageURLRequest() {
            var modifiedRequest = request
            modifiedRequest.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/22A3354", forHTTPHeaderField: "User-Agent")
            modifiedRequest.httpShouldHandleCookies = true
            
            webViewRequest.value = modifiedRequest
            isLoading.value = false
            print("마이페이지 웹뷰 로딩")
            return modifiedRequest
        } else {
            errorMessage.value = "URL 로딩 실패"
            isLoading.value = false
            return nil
        }
    }
    
    func loginCheckURLLoad() -> URLRequest? {
        if var request = urlManager.loginCheckURLRequest() {
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            // 모바일 User-Agent 추가
            request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/22A3354", forHTTPHeaderField: "User-Agent")
            return request
        }
        return nil
    }
}
