//
//  JoinViewController.swift
//  5GCAMP
//
//  Created by WONJI HA on 3/7/25.
//

import UIKit
import WebKit

final class JoinViewController: UIViewController {
    @IBOutlet weak var joinNavigationBar: UINavigationBar!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var joinButton: UIButton!
    
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    private let joinViewModel = JoinViewModel()
    var agreements: [AgreementType: Bool]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupNavigationBar()
        setupTextField()
        setupButtons()
    }
    
    private func setupNavigationBar() {
        joinNavigationBar.setBackgroundImage(UIImage(), for: .default)
        joinNavigationBar.shadowImage = UIImage()
        joinNavigationBar.isTranslucent = true
        joinNavigationBar.backgroundColor = UIColor.clear
    }
    
    private func setupTextField() {
        idTextField.delegate = self
        emailTextField.delegate = self
        nickNameTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        idTextField.layer.cornerRadius = 12
        emailTextField.layer.cornerRadius = 12
        nickNameTextField.layer.cornerRadius = 12
        passwordTextField.layer.cornerRadius = 12
        confirmPasswordTextField.layer.cornerRadius = 12
        
        idTextField.setPlacheholderColor(.systemGray)
        emailTextField.setPlacheholderColor(.systemGray)
        nickNameTextField.setPlacheholderColor(.systemGray)
        passwordTextField.setPlacheholderColor(.systemGray)
        confirmPasswordTextField.setPlacheholderColor(.systemGray)
    }
    
    private func setupButtons() {
        joinButton.layer.cornerRadius = 12
        
        let boldFont = UIFont.boldSystemFont(ofSize: 25)
        let attributeTitle = NSAttributedString(
            string: joinButton.title(for: .normal) ?? "회원가입",
            attributes: [NSAttributedString.Key.font: boldFont]
        )
        
        joinButton.setAttributedTitle(attributeTitle, for: .normal)
        joinButton.setAttributedTitle(attributeTitle, for: .highlighted)
        joinButton.setAttributedTitle(attributeTitle, for: .selected)
    }
    
    @IBAction func tappedBackButton(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func gesturedLeft(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func tappedJoinButton(_ sender: UIButton) {
        guard validateInputs() else { return }
        
        // 회원가입 버튼 클릭 시 아이디 중복 체크 한 번 더 수행
        if let id = idTextField.text, !id.isEmpty {
            joinViewModel.checkIdDuplication(id: id) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let isAvailable):
                        if isAvailable {
                            // 아이디 사용 가능한 경우 회원가입 진행
                            self?.registerUser()
                        } else {
                            // 아이디 중복인 경우 알림 표시
                            self?.showJoinAlert(title: "아이디 중복", message: "이미 사용 중인 아이디입니다. 다른 아이디를 입력해주세요.")
                            self?.idTextField.text = ""
                            self?.idTextField.becomeFirstResponder()
                        }
                    case .failure(let error):
                        self?.showJoinAlert(title: "오류", message: "아이디 중복 확인 중 오류가 발생했습니다: \(error.localizedDescription)")
                    }
                }
            }
        } else {
            registerUser()
        }
    }
    
    private func validateInputs() -> Bool {
        guard let id = idTextField.text, !id.isEmpty else {
            showJoinAlert(title: "알림", message: "아이디를 입력해주세요.")
            return false
        }
        
        guard let email = emailTextField.text, !email.isEmpty else {
            showJoinAlert(title: "알림", message: "이메일을 입력해주세요.")
            return false
        }
        
        guard let nickName = nickNameTextField.text, !nickName.isEmpty else {
            showJoinAlert(title: "알림", message: "닉네임을 입력해주세요.")
            return false
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            showJoinAlert(title: "알림", message: "비밀번호를 입력해주세요.")
            return false
        }
        
        guard let confirmPassword = confirmPasswordTextField.text, confirmPassword == password else {
            showJoinAlert(title: "알림", message: "비밀번호가 일치하지 않습니다.")
            return false
        }
        return true
    }
}

extension JoinViewController {
    
    private func setupBindings() {
        joinViewModel.isLoading.bind { [weak self] isLoading in
            DispatchQueue.main.async {
                if isLoading {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
                self?.joinButton.isEnabled = !isLoading
            }
        }
        
        joinViewModel.errorMessage.bind { errorMessage in
            if let errorMessage = errorMessage {
                print("오류", errorMessage)
            }
        }
    }
    
    private func registerUser() {
        guard let agreements = agreements else {
            showJoinAlert(title: "오류", message: "약관 동의 정보가 없습니다.")
            return
        }
        
        let userData = [
            "id": idTextField.text ?? "",
            "email": emailTextField.text ?? "",
            "nic": nickNameTextField.text ?? "",
            "pw1": passwordTextField.text ?? "",
            "pw2": confirmPasswordTextField.text ?? ""
        ]
        
        joinViewModel.registerUser(with: userData, agreements: agreements) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.showJoinAlert(title: "회원가입 성공", message: "회원가입이 완료되었습니다.")
                    // 회원가입 성공시 자동 로그인
                    self?.autoLoginAfterRegistration(id: userData["id"] ?? "", password: userData["pw1"] ?? "")
                case .failure(let error):
                    self?.showJoinAlert(title: "오류", message: "회원가입에 실패했습니다.")
                    print("회원가입 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func autoLoginAfterRegistration(id: String, password: String) {
        // 로그인 요청 생성
        guard var loginURL = joinViewModel.createLoginURLRequest() else {
            return print("회원가입중 로그인 URL 생성 실패")
        }
        
        loginURL.httpMethod = "POST"
        loginURL.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        loginURL.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/22A3354", forHTTPHeaderField: "User-Agent")
        
        // 로그인 파라미터 설정
        let parameters: [String: String] = [
            "id": id,
            "pw": password
        ]
        
        let postString = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        loginURL.httpBody = postString.data(using: .utf8)
        
        // 로그인 요청 전송
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.httpShouldSetCookies = true
        sessionConfig.httpCookieAcceptPolicy = .always
        let session = URLSession(configuration: sessionConfig)
        
        session.dataTask(with: loginURL) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showJoinAlert(title: "로그인 오류", message: error.localizedDescription)
                    self?.moveToLoginView()
                    return
                }
                
                // 쿠키 동기화 (중요!)
                self?.syncCookiesToWebView { [weak self] in
                    // 로그인 성공 처리 및 알림
                    self?.showJoinAlert(title: "로그인 성공", message: "로그인이 완료되었습니다.") {
                        // 로그인 성공 알림 전송
                        NotificationCenter.default.post(name: NSNotification.Name("LoginSuccessful"), object: nil)
                        
                        // 루트 뷰 컨트롤러로 돌아가기
                        self?.view.window?.rootViewController?.dismiss(animated: true) {
                            // 탭바 컨트롤러의 마이페이지 탭으로 이동
                            if let tabBarController = UIApplication.shared.windows.first?.rootViewController as? UITabBarController {
                                tabBarController.selectedIndex = 4 // 마이페이지 탭 인덱스
                                
                                // 마이페이지 웹뷰 강제 리로드
                                if let myPageVC = tabBarController.viewControllers?[4] as? MyPageViewController {
                                    myPageVC.reloadWebViewWithDelay()
                                }
                            }
                        }
                    }
                }
            }
        }.resume()
    }
    
    // 쿠키 동기화 메서드 추가
    private func syncCookiesToWebView(completion: @escaping () -> Void) {
        guard let cookies = HTTPCookieStorage.shared.cookies else {
            completion()
            return
        }
        
        for cookie in cookies {
            print("쿠키 동기화: \(cookie.name) = \(cookie.value)")
        }
        
        let cookieStore = WKWebsiteDataStore.default().httpCookieStore
        let group = DispatchGroup()
        
        for cookie in cookies {
            group.enter()
            cookieStore.setCookie(cookie) {
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            // 쿠키 동기화 완료 후 지연시간 추가
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                completion()
            }
        }
    }
    
    private func moveToLoginView() {
        self.view.window?.rootViewController?.dismiss(animated: true)
    }
    
    private func showJoinAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            completion?()
        })
        self.present(alertController, animated: true)
    }
}

extension JoinViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.idTextField {
            self.emailTextField.becomeFirstResponder()
        } else if textField == self.emailTextField {
            self.nickNameTextField.becomeFirstResponder()
        } else if textField == self.nickNameTextField {
            self.passwordTextField.becomeFirstResponder()
        } else if textField == self.passwordTextField {
            self.confirmPasswordTextField.becomeFirstResponder()
        } else if textField == self.confirmPasswordTextField {
            self.tappedJoinButton(self.joinButton)
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // MARK: - 글자 백스페이스&삭제 키 허용
        if string.isEmpty {
            return true
        }
        /// 닉네임 필드인 경우
        if textField == self.nickNameTextField {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            return updatedText.count <= 10
            
        } else {
            // MARK: - 한글 입력 방지
            if string.range(of: "^[a-zA-Z0-9@.!#$%&'*+/=?^_`{|}~-]+$", options: .regularExpression) == nil {
                return false
            }
        }
        
        // MARK: - 글자수 최대 길이 제한
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        /// 아이디 필드인 경우
        if textField == self.idTextField {
            return updatedText.count <= 20
        }
        
        /// 이메일 필드인 경우
        else if textField == self.emailTextField {
            return updatedText.count <= 50
        }
        
        /// 비밀번호 필드인 경우
        else if textField == self.passwordTextField || textField == self.confirmPasswordTextField {
            return updatedText.count <= 20
        }
        
        return updatedText.count <= 50
    }
}
