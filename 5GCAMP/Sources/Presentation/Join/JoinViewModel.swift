//
//  JoinViewModel.swift
//  5GCAMP
//
//  Created by WONJI HA on 12/9/24.
//

import Foundation

final class JoinViewModel {
    private let urlManager: URLManager
    private(set) var webViewRequest: Observable<URLRequest?> = Observable(nil)
    private(set) var isLoading: Observable<Bool> = Observable(false)
    private(set) var errorMessage: Observable<String?> = Observable(nil)
    
    init(urlManager: URLManager = URLManager()) {
        self.urlManager = urlManager
    }
    
    func termsOfUseURLRequest() -> URLRequest? {
        if let request = urlManager.joinURLRequest() {
            return request
        }
        return nil
    }
    
    func checkIdDuplication(id: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        isLoading.value = true
        
        // 아이디 중복 체크 URL 생성
        guard let url = URL(string: "https://www.5gcamp.com/?r=home&m=member&a=same_check&fname=id&fvalue=\(id)") else {
            isLoading.value = false
            completion(.failure(NSError(domain: "JoinViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "URL 생성 실패"])))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading.value = false
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data, let responseString = String(data: data, encoding: .utf8) else {
                    completion(.failure(NSError(domain: "JoinViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "응답 데이터 읽기 실패"])))
                    return
                }
                
                // 서버 응답에 "사용할 수 없는 아이디입니다" 문구가 포함되어 있는지 확인
                let isAvailable = !responseString.contains("사용할 수 없는 아이디입니다")
                completion(.success(isAvailable))
            }
        }
        task.resume()
    }
    
    func createLoginURLRequest() -> URLRequest? {
        return URLRequest(url: URL(string: "https://\(urlManager.mainDomain)/?r=home&a=login")!)
    }
    
    // 회원가입 API 호출
    func registerUser(with userData: [String: String], agreements: [AgreementType: Bool], completion: @escaping (Result<Bool, Error>) -> Void) {
        isLoading.value = true
        errorMessage.value = nil
        
        // 약관 동의 파라미터 구성
        var agreementParams: [String: String] = [:]
        for (type, isAgreed) in agreements {
            if isAgreed {
                agreementParams[type.parameterName] = "1"
            }
        }
        
        // MARK: - 필수 검증 필드
        var allParams = userData
        allParams[""] = ""
        allParams[""] = ""
        allParams[""] = ""
        
        // 약관 동의 파라미터 추가
        for (key, value) in agreementParams {
            allParams[key] = value
        }
        
        // URLManager를 사용하여 URL 생성
        guard let request = urlManager.joinWithAgreementsURLRequest(agreements: agreements) else {
            isLoading.value = false
            errorMessage.value = "URL 생성에 실패했습니다."
            completion(.failure(NSError(domain: "JoinViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "URL 생성 실패"])))
            return
        }
        
        // 요청 메서드와 헤더 설정
        var modifiedRequest = request
        modifiedRequest.httpMethod = "POST"
        modifiedRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // 파라미터를 URL 인코딩
        let postString = allParams.map { key, value in
            let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? key
            let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
            return "\(encodedKey)=\(encodedValue)"
        }.joined(separator: "&")
        
        modifiedRequest.httpBody = postString.data(using: .utf8)
        
        // 쿠키 처리를 위한 URLSession 구성
        let configuration = URLSessionConfiguration.default
        configuration.httpShouldSetCookies = true
        configuration.httpCookieAcceptPolicy = .always
        let session = URLSession(configuration: configuration)
        
        // API 호출
        let task = session.dataTask(with: modifiedRequest) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading.value = false
                
                if let error = error {
                    self?.errorMessage.value = "네트워크 오류: \(error.localizedDescription)"
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self?.errorMessage.value = "서버 응답 오류"
                    completion(.failure(NSError(domain: "JoinViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "서버 응답 오류"])))
                    return
                }
                
                if let data = data, let htmlString = String(data: data, encoding: .utf8) {
                    print("서버 응답: \(htmlString)")
                    
                    // 회원가입 성공 여부 확인 (성공 메시지 또는 오류 메시지 확인)
                    if htmlString.contains("회원가입이 완료되었습니다") ||
                        !htmlString.contains("오류") && !htmlString.contains("사용할 수 없는") {
                        completion(.success(true))
                    } else {
                        let errorMessage = "회원가입 처리 중 오류가 발생했습니다."
                        self?.errorMessage.value = errorMessage
                        completion(.failure(NSError(domain: "JoinViewModel", code: 2, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                    }
                } else {
                    self?.errorMessage.value = "데이터 처리 오류"
                    completion(.failure(NSError(domain: "JoinViewModel", code: 3, userInfo: [NSLocalizedDescriptionKey: "데이터 처리 오류"])))
                }
            }
        }
        task.resume()
    }
    
    private func validateField(field: String, value: String, completion: @escaping (Bool) -> Void) {
        // 필드 검증 API 호출 (id, nic, email)
        guard let url = URL(string: "https://www.5gcamp.com/?r=home&m=member&a=same_check&fname=\(field)&fvalue=\(value)") else {
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    // 검증 성공 여부 확인
                    let isValid = !responseString.contains("사용할 수 없는")
                    completion(isValid)
                } else {
                    completion(false)
                }
            }
        }.resume()
    }
}
