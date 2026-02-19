//
//  CampingListDistanceViewModel.swift
//  5GCAMP
//
//  Created by WONJI HA on 11/12/24.
//

import Foundation

final class CampingListDistanceViewModel {
    private let urlManager: URLManager
    
    private(set) var webViewRequest: Observable<URLRequest?> = Observable(nil)
    private(set) var isLoading: Observable<Bool> = Observable(false)
    private(set) var errorMessage: Observable<String?> = Observable(nil)
    
    init(urlManager: URLManager = URLManager()) {
        self.urlManager = urlManager
    }
    
    func loadWebView() {
        isLoading.value = true
        if let request = urlManager.campingListDistanceURLRequest() {
            webViewRequest.value = request
            isLoading.value = false
            print("웹뷰 로딩")
        } else {
            errorMessage.value = "URL 로딩 실패"
            isLoading.value = false
        }
    }
}
