//
//  ThirdPartySharingViewController.swift
//  5GCAMP
//
//  Created by Wonji Ha on 3/8/25.
//

import UIKit
import WebKit

// MARK: - 개인정보 제3자 제공동의 약관 -
final class ThirdPartySharingViewController: UIViewController {
    @IBOutlet weak var thirdPartSharingWebView: WKWebView!
    private let joinViewModel = JoinViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTerms()
    }
    
    @IBAction func tappedCloseButton(_ sender: Any) {
        dismiss(animated: true)
    }
}

extension ThirdPartySharingViewController {
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
                    return print("[개인정보 제3자 제공동의 약관] 네트워크 오류:", error.localizedDescription)
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    return print("[개인정보 제3자 제공동의 약관] 잘못된 응답 형식")
                }
                
                print("[개인정보 제3자 제공동의 약관] HTTP Status Code: \(httpResponse.statusCode)")
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    self?.showTermsAlert(title: "오류", message: "서버 오류입니다. 잠시 후 다시 시도 해주세요.\n오류코드 : \(httpResponse.statusCode)")
                    return
                }
                
                guard let data = data, let htmlString = String(data: data, encoding: .utf8) else {
                    self?.showTermsAlert(title: "오류", message: "약관 데이터를 읽을 수 없습니다. 잠시 후 다시 시도 해주세요.")
                    return
                }
                
                if let extractedContent = self?.extractAgreementContent(from: htmlString) {
                    let formattedHTML = self?.formatHTMLForWebView(extractedContent) ?? extractedContent
                    self?.thirdPartSharingWebView.loadHTMLString(formattedHTML, baseURL: nil)
                } else {
                    self?.showTermsAlert(title: "오류", message: "약관 내용을 불러올 수 없습니다.")
                }
            }
        }.resume()
    }
    
    private func extractAgreementContent(from htmlString: String) -> String? {
        let patterns = [
            "var agreetext = \\{[^{]*?4: `([\\s\\S]*?)`[^}]*?\\};",  // 백틱 버전
            "var agreetext = \\{[^{]*?4: '([\\s\\S]*?)'[^}]*?\\};",  // 작은따옴표 버전
            "var agreetext = \\{[^{]*?4: \"([\\s\\S]*?)\"[^}]*?\\};" // 큰따옴표 버전
        ]
        
        for pattern in patterns {
            do {
                let regex = try NSRegularExpression(pattern: pattern, options: [])
                let nsString = htmlString as NSString
                let range = NSRange(location: 0, length: nsString.length)
                
                if let match = regex.firstMatch(in: htmlString, options: [], range: range) {
                    let matchRange = match.range(at: 1)
                    if matchRange.location != NSNotFound {
                        let extractedHTML = nsString.substring(with: matchRange)
                        return unescapeHTML(extractedHTML)
                    }
                }
            } catch {
                print("[개인정보 제3자 제공동의 약관]정규식 오류: \(error.localizedDescription)")
            }
        }
        
        if let divContent = extractDivContent(from: htmlString, divId: "ag4") {
            return divContent
        }
        
        return nil
    }
    
    private func extractDivContent(from htmlString: String, divId: String) -> String? {
        let pattern = "<div id=\"\(divId)\"[^>]*>(.*?)</div>"
        let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])
        
        if let regex = regex, let match = regex.firstMatch(in: htmlString, options: [], range: NSRange(htmlString.startIndex..., in: htmlString)) {
            let range = Range(match.range(at: 1), in: htmlString)
            return String(htmlString[range!])
        }
        
        return nil
    }
    
    private func unescapeHTML(_ html: String) -> String {
        return html.replacingOccurrences(of: "\\'", with: "'")
            .replacingOccurrences(of: "\\\"", with: "\"")
            .replacingOccurrences(of: "\\n", with: "\n")
            .replacingOccurrences(of: "\\t", with: "\t")
            .replacingOccurrences(of: "\\r", with: "\r")
    }
    
    private func formatHTMLForWebView(_ htmlContent: String) -> String {
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=YES">
            <style>
                body { 
                    font-family: -apple-system, BlinkMacSystemFont, 'San Francisco', Helvetica, Arial, sans-serif;
                    margin: 10px;
                    line-height: 1.4;
                }
                table { 
                    border-collapse: collapse; 
                    width: 100%; 
                    margin-bottom: 15px;
                }
                th, td { 
                    border: 1px solid #dddddd; 
                    text-align: left; 
                    padding: 8px; 
                }
                th { 
                    background-color: #f2f2f2; 
                    text-align: center;
                    font-weight: bold;
                }
                h3 {
                    margin-top: 10px;
                    margin-bottom: 15px;
                }
            </style>
        </head>
        <body>
            \(htmlContent)
        </body>
        </html>
        """
    }
    
    private func showTermsAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default))
        self.present(alertController, animated: true)
    }
}
