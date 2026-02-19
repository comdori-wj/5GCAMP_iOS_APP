//
//  FindPasswordViewController.swift
//  5GCAMP
//
//  Created by WONJI HA on 3/6/25.
//

import UIKit

final class FindPasswordViewController: UIViewController {
    @IBOutlet weak var findPasswordNavigationBar: UINavigationBar!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var findPasswordButton: UIButton!
    
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
        findPasswordNavigationBar.setBackgroundImage(UIImage(), for: .default)
        findPasswordNavigationBar.shadowImage = UIImage()
        findPasswordNavigationBar.isTranslucent = true
        findPasswordNavigationBar.backgroundColor = UIColor.clear
    }
    
    private func setupTextField() {
        idTextField.delegate = self
        emailTextField.delegate = self
        idTextField.setPlacheholderColor(.systemGray)
        emailTextField.setPlacheholderColor(.systemGray)
    }
    
    private func setUpButtons() {
        findPasswordButton.layer.cornerRadius = 12
        
        let boldFont = UIFont.boldSystemFont(ofSize: 25)
        let attributeTitle = NSAttributedString(
            string: findPasswordButton.title(for: .normal) ?? "비밀번호 찾기",
            attributes: [NSAttributedString.Key.font: boldFont]
        )
        
        findPasswordButton.setAttributedTitle(attributeTitle, for: .normal)
        findPasswordButton.setAttributedTitle(attributeTitle, for: .highlighted)
        findPasswordButton.setAttributedTitle(attributeTitle, for: .selected)
    }
    
    @IBAction func tappedBackButton(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func gesturedLeft(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func tappedPasswordButton(_ sender: UIButton) {
        guard let id: String = idTextField.text, !id.isEmpty else {
            return showFindAccountAlert(title: "오류", message: "아이디를 입력해 주세요!")
        }
        
        guard let email: String = emailTextField.text, !email.isEmpty else {
            return showFindAccountAlert(title: "오류", message: "이메일을 입력해 주세요!")
        }
        
        findPassword(id: id, email: email)
    }
}

extension FindPasswordViewController {
    
    private func findPassword(id: String, email: String) {
        guard var request = findAccountViewModel.findAccountURLLoad() else {
            return print("[비밀번호찾기] url 요청 생성 실패")
        }
        
        let parameters: [String: Any] = [
            "id" : id,
            "email" : email
        ]
        
        let postString = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        request.httpBody = postString.data(using: .utf8)
        
        print("보내는값: ", postString)
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    return print("[비번찾기] 네트워크 오류 : ", error.localizedDescription)
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    return print("[비번찾기] 잘못된 응답 형식")
                }
                
                print("[비번찾기] HTTP Status Code: \(httpResponse.statusCode)")
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    self?.showFindAccountAlert(title: "오류", message: "서버 오류입니다. 잠시 후 다시 시도 해주세요.\n오류코드 : \(httpResponse.statusCode)")
                    return
                }
                
                guard let data = data, let htmlString = String(data: data, encoding: .utf8) else {
                    self?.showFindAccountAlert(title: "오류", message: "데이터 처리 오류 입니다. 잠시 후 다시 시도 해주세요.")
                    return
                }
                
                print("[비번찾기]Server Response: \(htmlString)")
                
                if htmlString.contains("입력하신 E-MAIL 로 일치하는 회원데이터가 없습니다.") {
                    self?.showFindAccountAlert(title: "비밀번호 찾기 실패", message: "입력하신 이메일로 비밀번호를 찾을 수 없습니다.")
                }
                
                if htmlString.contains("입력하신 ID 로 일치하는 회원데이터가 없습니다.") {
                    self?.showFindAccountAlert(title: "비밀번호 찾기 실패", message: "입력하신 아이디를 찾을 수 없습니다.")
                }
                
                else if let password = self?.extractPassword(from: htmlString) {
                    self?.showFindAccountAlert(title: "임시 비밀번호 발급 성공", message: "회원님의 이메일 \(email)로 임시 비밀번호를 보냈습니다. 로그인 후 비밀번호를 변경해 주시기를 바랍니다.")
                } else {
                    self?.showFindAccountAlert(title: "오류", message: "죄송합니다.\n문제가 발생하여 임시 비밀번호를 전송하지 못했습니다.\n잠시 후 다시 시도 부탁드립니다.")
                }
            }
        }
        task.resume()
    }
    
    private func extractPassword(from html: String) -> String? {
        // 정규 표현식 패턴. 대괄호 안의 내용을 캡처
        let pattern = "회원님의 이메일\\[([^\\]]+)\\]로   \n임시 비밀번호를 발송해 드렸습니다."
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
        let okAction = UIAlertAction(title: "확인", style: .default)
        alertController.addAction(okAction)
        self.present(alertController, animated: true)
    }
}

extension FindPasswordViewController: UITextFieldDelegate {
    
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
        
        if textField == self.idTextField {
            return updatedText.count <= 20
        }
        else if textField == self.emailTextField {
            return updatedText.count <= 50
        }
        return updatedText.count <= 50
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text, !isValidText(text) {
            return print("유효하지 않은 문자 입력:", text)
        }
    }
    
    func isValidText(_ text: String) -> Bool {
        let textRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let textPred = NSPredicate(format:"SELF MATCHES %@", textRegEx)
        return textPred.evaluate(with: text)
    }
}
