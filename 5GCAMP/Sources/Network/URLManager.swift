//
//  URLManager.swift
//  5GCAMP
//
//  Created by WONJI HA on 11/6/24.
//

import UIKit

struct URLManager {
    private(set) var mainDomain = "www.5gcamp.com"
    private let paths: [String: String] = [
        "main": "",
        "campingListDistance": "/?r=home&c=camping&m=camping&p=1&sort=distance&orderby=asc",
        "campingListRecentUpdate": "/?r=home&c=camping&m=camping&p=1&sort=d_modify&orderby=asc",
        "map": "",
        "iPadMap": "",
        "mypage": "/?mod=mypage",
        "login": "/?mod=login&iframe=Y",
        "loginCheck": "/?_api=login_check&newapp=1",
        "findAccount": "",
        "join": "/?mod=join&iframe=Y"
    ]
    
    private func createURLRequest(for path: String) -> URLRequest? {
        let baseURL = "https://" + mainDomain + (paths[path] ?? "")
        guard let url = URL(string: baseURL) else {
            print("잘못된 주소: \(baseURL)")
            return nil
        }
        return URLRequest(url: url)
    }
    
    func mainURLRequest() -> URLRequest? {
        return createURLRequest(for: "main")
    }
    
    func campingListDistanceURLRequest() -> URLRequest? {
        return createURLRequest(for: "campingListDistance")
    }
    
    func campingListRecentUpdateURLRequest() -> URLRequest? {
        return createURLRequest(for: "campingListRecentUpdate")
    }
    
    func mapURLRequest() -> URLRequest? {
        let device = UIDevice.current.userInterfaceIdiom
        if device == .pad || device == .mac {
            print("접속 기기: iPad 또는 Mac")
            return createURLRequest(for: "iPadMap")
        } else {
            return createURLRequest(for: "map")
        }
    }
    
    func mypageURLRequest() -> URLRequest? {
        return createURLRequest(for: "mypage")
    }
    
    func loginURLRequest() -> URLRequest? {
        return createURLRequest(for: "login")
    }
    
    func loginCheckURLRequest() -> URLRequest? {
        return createURLRequest(for: "loginCheck")
    }
    
    func findAccountURLRequest() -> URLRequest? {
        return createURLRequest(for: "findAccount")
    }
    
    func joinURLRequest() -> URLRequest? {
        return createURLRequest(for: "join")
    }
}

extension URLManager {
    /// - Parameters:
    /// - agreements: 각 약관 동의 여부를 담은 딕셔너리
    /// - Returns: 회원가입 URL 요청 객체
    
    func joinWithAgreementsURLRequest(agreements: [AgreementType: Bool]) -> URLRequest? {
        // 기본 회원가입 URL 경로
        let basePath = "/?r=home&c=&m=home&front=join&mod=join&page=step3&comp=0&iframe=Y&agreement=Y"
        
        // 약관 동의 파라미터 구성
        var agreementParams = ""
        
        // 각 약관 동의 여부에 따라 파라미터 추가
        for (type, isAgreed) in agreements {
            if isAgreed {
                agreementParams += "&\(type.parameterName)=1"
            }
        }
        
        // 최종 URL 생성
        let fullPath = basePath + agreementParams
        
        let baseURL = "https://" + mainDomain + fullPath
        guard let url = URL(string: baseURL) else {
            print("잘못된 주소: \(baseURL)")
            return nil
        }
        
        return URLRequest(url: url)
    }
}
