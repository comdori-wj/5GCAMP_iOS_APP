//
//  LoginViewController.swift
//  5GCAMP
//
//  Created by WONJI HA on 12/6/24.
//

import UIKit
import WebKit
import CoreLocation

final class LoginViewController: UIViewController, WebViewConfigurable {
    var locationManager: CLLocationManager!
    var webView: WKWebView!
    
    @IBOutlet weak var loginNavigationBar: UINavigationBar!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var findIdButton: UIButton!
    @IBOutlet weak var findPasswordButton: UIButton!
    
    private let loginViewModel = LoginViewModel()
    private var isCheckingLogin = false
    private var hasCheckedLoginStatus = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkInitialLoginStatus()
        setupUI()
        loadAccountInfo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    private func setupUI() {
        setUpTextField()
        setUpNavigationBar()
        setUpButtons()
    }
    
    private func setUpNavigationBar() {
        loginNavigationBar.setBackgroundImage(UIImage(), for: .default)
        loginNavigationBar.shadowImage = UIImage()
        loginNavigationBar.isTranslucent = true
        loginNavigationBar.backgroundColor = UIColor.clear
    }
    
    private func setUpTextField() {
        idTextField.delegate = self
        idTextField.layer.cornerRadius = 12
        idTextField.setPlacheholderColor(.systemGray)
        passwordTextField.delegate = self
        passwordTextField.setPlacheholderColor(.systemGray)
        passwordTextField.layer.cornerRadius = 12
    }
    
    private func setUpButtons() {
        loginButton.layer.cornerRadius = 12
        
        let boldFont = UIFont.boldSystemFont(ofSize: 25)
        let attributeTitle = NSAttributedString(
            string: loginButton.title(for: .normal) ?? "로그인",
            attributes: [NSAttributedString.Key.font: boldFont]
        )
        
        loginButton.setAttributedTitle(attributeTitle, for: .normal)
        loginButton.setAttributedTitle(attributeTitle, for: .highlighted)
        loginButton.setAttributedTitle(attributeTitle, for: .selected)
        
        let attributedTitle = NSAttributedString(string: joinButton.title(for: .normal) ?? "회원가입",
                                                 attributes: [NSAttributedString.Key.font:
                                                                UIFont.systemFont(ofSize: 16, weight: .heavy)]
        )
        joinButton.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    @IBAction private func tappedCloseButton(_ sender: UIButton) {
        dismiss(animated: true)
        if let tabBarController = UIApplication.shared.windows.first?.rootViewController as? UITabBarController {
            tabBarController.selectedIndex = 2 // 탭바의 홈 인덱스로 이동
        }
    }
    
    @IBAction private func backLeftGesture(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction private func tappedLoginButton(_ sender: UIButton) {
        guard let id: String = idTextField.text, !id.isEmpty else {
            return showLoginAlert(message: "아이디를 입력해 주세요!")
        }
        
        guard let password: String = passwordTextField.text, !password.isEmpty else {
            return showLoginAlert(message: "비밀번호를 입력해 주세요!")
        }
        
        checkLoginStatus { [weak self] isLoggedIn in
            if isLoggedIn {
                print("이미 로그인 되어 있다")
                DispatchQueue.main.async {
                }
            } else {
                DispatchQueue.main.async {
                    self?.mainLogin(id: id, password: password)
                }
            }
        }
    }
    
    @IBAction func tappedFindIdButton(_ sender: Any) {
        moveToFindIdView()
    }
    
    @IBAction func tappedFindPasswordButton(_ sender: Any) {
        moveToFindPasswordView()
    }
    
    @IBAction private func tappedJoinButton(_ sender: UIButton) {
        moveToJoinView()
    }
    
    private func loadAccountInfo() {
        let myUserDefaults = UserDefaults.standard
        let userId = myUserDefaults.object(forKey: "save_id")
        let userPassword = myUserDefaults.object(forKey: "save_password")
        idTextField.text = userId as? String
        passwordTextField.text = userPassword as? String
    }
    
    private func checkLoginStatus(completion: @escaping (Bool) -> Void) {
        guard let checkLoginURLRequest = loginViewModel.loginCheckURLLoad() else {
            completion(false)
            return
        }
        
        let task = URLSession.shared.dataTask(with: checkLoginURLRequest) { (data, response, error) in
            if let error = error {
                print("로그인 상태 확인 데이터 통신 오류: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let data = data else {
                print("로그인 상태 확인 데이터 바인딩 실패")
                completion(false)
                return
            }
            
            // 서버 응답 로깅
            if let responseString = String(data: data, encoding: .utf8) {
                print("로그인 서버 응답: \(responseString)")
                
                // HTML 응답인지 확인
                if responseString.contains("<!DOCTYPE html") {
                    // HTML 응답이면 이전 로그인 성공 여부 확인
                    if let cookies = HTTPCookieStorage.shared.cookies,
                       cookies.contains(where: { $0.name == "PHPSESSID" }) {
                        // 세션 쿠키가 있으면 로그인 성공으로 간주
                        completion(true)
                    } else {
                        completion(false)
                    }
                    return
                }
                
                // JSON 파싱 시도
                do {
                    let decoder = JSONDecoder()
                    let loginStatus = try decoder.decode(LoginModel.self, from: data)
                    completion(loginStatus.status)
                } catch {
                    print("로그인 상태 확인 JSON 디코딩 오류: \(error.localizedDescription)")
                    
                    // JSON 파싱 실패 시 문자열에서 status 확인
                    if responseString.contains("\"status\":true") {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            } else {
                completion(false)
            }
        }
        task.resume()
    }
    
    private func mainLogin(id: String, password: String) {
        guard var loginURL = loginViewModel.loginURLLoad() else {
            return print("로그인 url 얻기 실패")
        }
        
        clearAllCookies { [weak self] in
            let parameters: [String: Any] = [
                "r": "",
                "a": "login",
                "referer": "",
                "id": id,
                "pw": password,
                "idpwsave": ""
            ]
            
            let postString = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
            loginURL.httpBody = postString.data(using: .utf8)
            
            // API 호출
            let task = URLSession.shared.dataTask(with: loginURL) { [weak self] (data, response, error) in
                if let httpResponse = response as? HTTPURLResponse {
                    // 상태 코드 확인
                    guard httpResponse.statusCode == 200 else {
                        self?.showLoginAlert(message: "로그인 처리 중 오류가 발생하였습니다.\n오류코드: 200")
                        return
                    }
                    
                    self?.syncCookies {
                        if let error = error {
                            self?.showLoginAlert(message: "로그인중 네트워크 오류가 발생했습니다.")
                            print("로그인 오류:", error.localizedDescription)
                            return
                        }
                        
                        if let data = data, let responseString = String(data: data, encoding: .utf8) {
                            print("로그인 응답: \(responseString)")
                            
                            // 첫 번째 로그인 응답이 JSON인지 확인
                            if responseString.contains("\"status\":true") {
                                DispatchQueue.main.async {
                                    NotificationCenter.default.post(name: NSNotification.Name("LoginSuccessful"), object: nil)
                                    self?.dismiss(animated: true)
                                }
                                return
                            }
                            
                            // 세션 쿠키 확인으로 로그인 성공 여부 판단
                            if let cookies = HTTPCookieStorage.shared.cookies,
                               let sessionCookie = cookies.first(where: { $0.name == "PHPSESSID" }) {
                                print("세션 쿠키 발견: \(sessionCookie.name)=\(sessionCookie.value)")
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    self?.checkLoginStatus { [weak self] isLoggedIn in
                                        self?.isCheckingLogin = false
                                        self?.hasCheckedLoginStatus = true
                                        
                                        if isLoggedIn {
                                            DispatchQueue.main.async {
                                                NotificationCenter.default.post(name: NSNotification.Name("LoginSuccessful"), object: nil)
                                                self?.dismiss(animated: true)
                                            }
                                        } else {
                                            self?.showLoginAlert(message: "로그인에 실패했습니다.\n아이디 또는 비밀번호를 확인해 주세요.")
                                        }
                                    }
                                }
                            } else {
                                print("로그인에 실패했습니다.\n세션 쿠키를 찾을 수 없습니다.")
                                self?.showLoginAlert(message: "로그인에 실패했습니다.\n코드: 2")
                            }
                        } else {
                            print("로그인 실패: 응답 데이터를 읽을 수 없습니다.")
                            self?.showLoginAlert(message: "로그인에 실패했습니다.\n코드: 3")
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    private func showLoginAlert(message: String) {
        DispatchQueue.main.async { [weak self] in
            let alertController = UIAlertController(title: "로그인 실패", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .default)
            alertController.addAction(okAction)
            self?.present(alertController, animated: true)
        }
    }
    
    private func moveToMyPage() {
        let storyBoard = UIStoryboard(name: "MyPage", bundle: nil)
        if let myPageViewController = storyBoard.instantiateViewController(withIdentifier: "MyPageView") as? MyPageViewController {
            myPageViewController.modalPresentationStyle = .currentContext
            if let tabBarController = UIApplication.shared.windows.first?.rootViewController as? UITabBarController {
                // 탭바의 마이페이지 인덱스로 이동
                tabBarController.selectedIndex = 4
                self.dismiss(animated: true)
            }
        }
    }
    
    private func moveToFindIdView() {
        let findAccountStoryBoard = UIStoryboard(name: "FindAccount", bundle: nil)
        if let findIdViewController = findAccountStoryBoard.instantiateViewController(withIdentifier: "FindIdView") as? FindIdViewController {
            findIdViewController.modalPresentationStyle = .fullScreen
            if let tabBarController = UIApplication.shared.windows.first?.rootViewController as? UITabBarController {
                tabBarController.selectedIndex = 4
                present(findIdViewController, animated: true)
            }
        }
    }
    
    private func moveToFindPasswordView() {
        let findAccountStoryBoard = UIStoryboard(name: "FindAccount", bundle: nil)
        if let findPasswordViewController = findAccountStoryBoard.instantiateViewController(withIdentifier: "FindPasswordView") as? FindPasswordViewController {
            findPasswordViewController.modalPresentationStyle = .overFullScreen
            if let tabBarController = UIApplication.shared.windows.first?.rootViewController as? UITabBarController {
                tabBarController.selectedIndex = 4
                present(findPasswordViewController, animated: true)
            }
        }
    }
    
    private func moveToJoinView() {
        let storyBoard = UIStoryboard(name: "Join", bundle: nil)
        if let termsOfUseViewController = storyBoard.instantiateViewController(withIdentifier: "TermsOfUseView") as? TermsOfUseViewController {
            termsOfUseViewController.modalPresentationStyle = .overFullScreen
            if let tabBarController = UIApplication.shared.windows.first?.rootViewController as? UITabBarController {
                tabBarController.selectedIndex = 4
                present(termsOfUseViewController, animated: true)
            }
        }
    }
    
    private func checkInitialLoginStatus() {
        guard !isCheckingLogin, !hasCheckedLoginStatus else { return }
        isCheckingLogin = true
        checkLoginStatus { [weak self] isLoggedIn in
            self?.isCheckingLogin = false
            self?.hasCheckedLoginStatus = true
            
            if isLoggedIn {
                DispatchQueue.main.async {
                    self?.moveToMyPage()
                }
            }
        }
    }
    
    private func syncCookies(completion: @escaping () -> Void) {
        guard let cookies = HTTPCookieStorage.shared.cookies else {
            completion()
            return
        }
        
        for cookie in cookies {
            print("쿠키: \(cookie.name) = \(cookie.value)")
        }
        
        DispatchQueue.main.async {
            let cookieStore = WKWebsiteDataStore.default().httpCookieStore
            let group = DispatchGroup()
            cookies.forEach { cookie in
                group.enter()
                cookieStore.setCookie(cookie) {
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                completion()
            }
        }
    }
    
    private func validateSession(completion: @escaping (Bool) -> Void) {
        // 서버 응답의 status 필드를 직접 확인
        guard let checkURL = loginViewModel.loginCheckURLLoad() else {
            completion(false)
            return
        }
        
        let task = URLSession.shared.dataTask(with: checkURL) { data, response, error in
            if let data = data,
               let responseString = String(data: data, encoding: .utf8) {
                print("세션 검증 응답: \(responseString)")
                
                // JSON 파싱 시도
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let status = json["status"] as? Bool {
                        completion(status)
                    } else {
                        completion(false)
                    }
                } catch {
                    print("JSON 파싱 오류: \(error)")
                    // JSON 파싱 실패 시에도 로그인 성공으로 처리
                    // 서버 응답에 status:true가 포함되어 있는지 문자열로 확인
                    if responseString.contains("\"status\":true") {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            } else {
                completion(false)
            }
        }
        task.resume()
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) { }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.idTextField {
            self.passwordTextField.becomeFirstResponder()
        } else if textField == self.passwordTextField {
            self.tappedLoginButton(self.loginButton)
        }
        return true
    }
    
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
        else if textField == self.passwordTextField {
            return updatedText.count <= 20
        }
        return updatedText.count <= 30
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

extension LoginViewController: TabBarProtocol {
    func reloadView() {
        hasCheckedLoginStatus = false
        checkInitialLoginStatus()
    }
}
