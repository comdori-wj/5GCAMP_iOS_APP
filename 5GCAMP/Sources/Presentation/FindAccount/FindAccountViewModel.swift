//
//  FindAccountViewModel.swift
//  5GCAMP
//
//  Created by WONJI HA on 12/9/24.
//

import Foundation

final class FindAccountViewModel {
    private let urlManager: URLManager
    
    private(set) var webViewRequest: Observable<URLRequest?> = Observable(nil)
    private(set) var isLoading: Observable<Bool> = Observable(false)
    private(set) var errorMessage: Observable<String?> = Observable(nil)
    
    init(urlManager: URLManager = URLManager()) {
        self.urlManager = urlManager
    }
    
    func findAccountURLLoad() -> URLRequest? {
        if var request = urlManager.findAccountURLRequest() {
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/22A3354", forHTTPHeaderField: "User-Agent")
            return request
        }
        return nil
    }
}
