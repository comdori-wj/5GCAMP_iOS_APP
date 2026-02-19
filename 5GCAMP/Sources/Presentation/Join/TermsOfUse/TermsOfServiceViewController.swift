//
//  TermsOfServiceViewController.swift
//  5GCAMP
//
//  Created by Wonji Ha on 3/8/25.
//

import UIKit

// MARK: - 서비스 이용 약관 -
final class TermsOfServiceViewController: UIViewController {
    @IBOutlet weak var termsOfServiceTextView: UITextView!
    private let joinViewModel = JoinViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTerms()
        
    }
    
    @IBAction func tappedCloseButton(_ sender: Any) {
        dismiss(animated: true)
    }
}

extension TermsOfServiceViewController {
    
    private func loadTerms() {
        guard let requset = joinViewModel.termsOfUseURLRequest() else {
            return print("약관 URL 불러오기 실패")
        }
        
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = 120
        
        let session = URLSession(configuration: sessionConfiguration)
        
        session.dataTask(with: requset) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    return print("[서비스 이용약관] 네트워크 오류:", error.localizedDescription)
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    return print("[서비스 이용약관] 잘못된 응답 형식")
                }
                
                print("[서비스 이용약관] HTTP Status Code: \(httpResponse.statusCode)")
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    self?.showTermsAlert(title: "오류", message: "서버 오류입니다. 잠시 후 다시 시도 해주세요.\n오류코드 : \(httpResponse.statusCode)")
                    return
                }
                
                guard let data = data, let htmlString = String(data: data, encoding: .utf8) else {
                    self?.showTermsAlert(title: "오류", message: "약관 데이터를 읽을 수 없습니다. 잠시 후 다시 시도 해주세요.")
                    return
                }
                
                if let extensionContext = self?.extractAgreementContent(from: htmlString) {
                    let formattedContent = self?.formatHTMLContent(extensionContext) ?? extensionContext
                    self?.termsOfServiceTextView.text = formattedContent
                } else {
                    self?.showTermsAlert(title: "오류", message: "약관 내용을 불러올 수 없습니다.")
                }
            }
        }.resume()
    }
    
    private func extractAgreementContent(from htmlString: String) -> String? {
        // 정규식 패턴 개선 - 더 넓은 범위의 문자열 캡처
        let pattern = "var agreetext = \\{[^{]*?2: `([\\s\\S]*?)`[^}]*?\\};"
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let nsString = htmlString as NSString
            let range = NSRange(location: 0, length: nsString.length)
            
            if let match = regex.firstMatch(in: htmlString, options: [], range: range) {
                let matchRange = match.range(at: 1)
                if matchRange.location != NSNotFound {
                    return nsString.substring(with: matchRange)
                }
            }
            
            // 첫 번째 패턴이 실패하면 백틱 대신 작은따옴표를 사용하는 패턴 시도
            let alternativePattern = "var agreetext = \\{[^{]*?2: '([\\s\\S]*?)'[^}]*?\\};"
            let alternativeRegex = try NSRegularExpression(pattern: alternativePattern, options: [])
            
            if let match = alternativeRegex.firstMatch(in: htmlString, options: [], range: range) {
                let matchRange = match.range(at: 1)
                if matchRange.location != NSNotFound {
                    return nsString.substring(with: matchRange)
                }
            }
        } catch {
            print("정규식 오류: \(error.localizedDescription)")
        }
        return nil
    }
    
    private func formatHTMLContent(_ htmlContent: String) -> String {
        // HTML 태그 제거 및 특수 문자 처리
        var formattedContent = htmlContent
        
        // <br/>, <br> 태그를 줄바꿈으로 변환
        formattedContent = formattedContent.replacingOccurrences(of: "<br/>", with: "\n")
        formattedContent = formattedContent.replacingOccurrences(of: "<br>", with: "\n")
        
        // 기타 HTML 태그 제거
        formattedContent = formattedContent.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        
        // HTML 엔티티 디코딩
        formattedContent = formattedContent.replacingOccurrences(of: "&nbsp;", with: " ")
        formattedContent = formattedContent.replacingOccurrences(of: "&lt;", with: "<")
        formattedContent = formattedContent.replacingOccurrences(of: "&gt;", with: ">")
        formattedContent = formattedContent.replacingOccurrences(of: "&amp;", with: "&")
        formattedContent = formattedContent.replacingOccurrences(of: "&quot;", with: "\"")
        
        return formattedContent
    }
    
    private func showTermsAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default))
        self.present(alertController, animated: true)
    }
}
