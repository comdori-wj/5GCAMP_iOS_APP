//
//  FindIdViewController.swift
//  5GCAMP
//
//  Created by WONJI HA on 3/4/25.
//

import UIKit

final class FindIdViewController: UIViewController {
    @IBOutlet weak var findIdNavigationBar: UINavigationBar!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var findIdButton: UIButton!
    
    private let findAccountViewModel = FindAccountViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    private func setupUI() {
        setUpNavigationBar()
        setupTextField()
        setUpButtons()
    }
    
    private func setUpNavigationBar() {
        findIdNavigationBar.setBackgroundImage(UIImage(), for: .default)
        findIdNavigationBar.shadowImage = UIImage()
        findIdNavigationBar.isTranslucent = true
        findIdNavigationBar.backgroundColor = UIColor.clear
    }
    
    private func setupTextField() {
        emailTextField.delegate = self
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        emailTextField.spellCheckingType = .no
        emailTextField.setPlacheholderColor(.systemGray)
    }
    
    private func setUpButtons() {
        findIdButton.layer.cornerRadius = 12
        
        let boldFont = UIFont.boldSystemFont(ofSize: 25)
        let attributeTitle = NSAttributedString(
            string: findIdButton.title(for: .normal) ?? "아이디 찾기",
            attributes: [NSAttributedString.Key.font: boldFont]
        )
        
        findIdButton.setAttributedTitle(attributeTitle, for: .normal)
        findIdButton.setAttributedTitle(attributeTitle, for: .highlighted)
        findIdButton.setAttributedTitle(attributeTitle, for: .selected)
    }
    
    @IBAction func tappedBackButton(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func gesturedLeft(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func tappedFindIdButton(_ sender: UIButton) {
        guard let email: String = emailTextField.text, !email.isEmpty else {
            return showFindAccountAlert(title: "오류", message: "이메일을 입력해 주세요!")
        }
        findId(email: email)
    }
}

extension FindIdViewController {
    private func findId(email: String) {
        guard var request = findAccountViewModel.findAccountURLLoad() else {
            return print("[아이디찾기] 요청 생성 실패")
        }
        
        let parameters: [String: Any] = [
            "email": email // php에서 사용하는 액션 파라미터
        ]
        
        let postString = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        request.httpBody = postString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    return print("[아이디찾기] 네트워크 오류: \(error.localizedDescription)")
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    return print("[아이디찾기] 잘못된 응답 형식")
                }
                
                print("[아이디찾기] HTTP Status Code: \(httpResponse.statusCode)")
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    self?.showFindAccountAlert(title: "오류", message: "서버 오류입니다. 잠시 후 다시 시도 해주세요.\n오류코드 : \(httpResponse.statusCode)")
                    return
                }
                
                guard let data = data, let htmlString = String(data: data, encoding: .utf8) else {
                    self?.showFindAccountAlert(title: "오류", message: "데이터 처리 오류 입니다. 잠시 후 다시 시도 해주세요.")
                    return
                }
                
                if htmlString.contains("입력하신 정보로 일치하는 회원데이터가 없습니다.") {
                    self?.showFindAccountAlert(title: "아이디 찾기 실패", message: "입력하신 이메일의 아이디를 찾을 수 없습니다.")
                }
                /// 응답에 아이디가 포함된 경우, "회원님의 아이디는 [xxx**] 입니다." 메시지를 파싱
                else if let id = self?.extractId(from: htmlString) {
                    self?.showFindAccountAlert(title: "아이디 찾기 성공", message: "회원님의 아이디는 [\(id)] 입니다.")
                } else {
                    self?.showFindAccountAlert(title: "오류", message: "아이디를 찾을 수 없거나, 서버 오류 입니다. 잠시후 다시시도 해주세요.")
                }
                
            }
        }
        task.resume()
    }
    
    /// HTML 응답에서 "회원님의 아이디는 [xxx**] 입니다." 메시지를 파싱하여 아이디 문자열만 추출
    private func extractId(from html: String) -> String? {
        // 정규 표현식 패턴. 대괄호 안의 내용을 캡처
        let pattern = "회원님의 아이디는 \\[([^\\]]+)\\] 입니다"
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let range = NSRange(html.startIndex..<html.endIndex, in: html)
            if let match = regex.firstMatch(in: html, options: [], range: range),
               let idRange = Range(match.range(at: 1), in: html) {
                return String(html[idRange])
            }
        }
        return nil
    }
    
    private func showFindAccountAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default))
        self.present(alertController, animated: true)
    }
}

extension FindIdViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // MARK: - 글자 백스페이스&삭제 키 허용
        if string.isEmpty {
            return true
        }
        
        // MARK: - 한글 입력 방지
        if string.range(of: "^[a-zA-Z0-9@.!#$%&'*+/=?^_`{|}~-]+$", options: .regularExpression) == nil {
            return false
        }
        
        // MARK: - 글자수 최대 길이 제한
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= 50
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let email = textField.text, !isValidEmail(email) {
            return print("유효하지 않은 이메일 입력:", email)
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
