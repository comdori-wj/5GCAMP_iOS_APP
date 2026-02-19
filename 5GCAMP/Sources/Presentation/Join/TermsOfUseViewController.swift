//
//  TermsOfUseViewController.swift
//  5GCAMP
//
//  Created by Wonji Ha on 3/9/25.
//

// 약관 동의 상태를 관리하는 열거형


import UIKit

final class TermsOfUseViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var termsOfUseNavigationBar: UINavigationBar!
    @IBOutlet weak var agreeAllStackView: UIStackView!
    @IBOutlet weak var joinNextButton: UIButton!
    
    // MARK: - 체크박스 이미지뷰
    @IBOutlet weak var agreeAllButton: UIImageView!
    @IBOutlet weak var ageVerificationButton: UIImageView!
    @IBOutlet weak var termsOfServiceButton: UIImageView!
    @IBOutlet weak var privacyPolicyButton: UIImageView!
    @IBOutlet weak var thirdPartySharingButton: UIImageView!
    @IBOutlet weak var locationBasedServiceConsentButton: UIImageView!
    @IBOutlet weak var marketingButton: UIImageView!
    @IBOutlet weak var dataRetentionButton: UIImageView!
    
    // MARK: - Properties
    weak var delegate: TermsOfUseViewControllerDelegates?
    private let checkOnImage = UIImage(named: "CheckOnIcon")
    private let checkOffImage = UIImage(named: "CheckOffIcon")
    
    // 약관 동의 상태를 관리하는 딕셔너리
    private var agreements: [AgreementType: Bool] = [
        .ageVerification: false,
        .termsOfService: false,
        .privacyPolicy: false,
        .thirdPartySharing: false,
        .locationBasedServiceConsent: false,
        .marketingConsent: false
    ]
    
    private var isAgreeAll: Bool = false {
        didSet {
            updateAgreeAllButton()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupNavigationBar()
        setupStackViews()
        setupButtons()
        setupImageViewTouchGestures()
        updateAllCheckboxes()
    }
    
    private func setupNavigationBar() {
        termsOfUseNavigationBar.setBackgroundImage(UIImage(), for: .default)
        termsOfUseNavigationBar.shadowImage = UIImage()
        termsOfUseNavigationBar.isTranslucent = true
        termsOfUseNavigationBar.backgroundColor = UIColor.clear
    }
    
    private func setupStackViews() {
        agreeAllStackView.layer.cornerRadius = 10
    }
    
    private func setupImageViewTouchGestures() {
        // 모든 이미지뷰에 사용자 상호작용 활성화
        agreeAllButton.isUserInteractionEnabled = true
        ageVerificationButton.isUserInteractionEnabled = true
        termsOfServiceButton.isUserInteractionEnabled = true
        privacyPolicyButton.isUserInteractionEnabled = true
        thirdPartySharingButton.isUserInteractionEnabled = true
        locationBasedServiceConsentButton.isUserInteractionEnabled = true
        marketingButton.isUserInteractionEnabled = true
        
        let agreeAllTap = UITapGestureRecognizer(target: self, action: #selector(agreeAllTapped))
        let ageVerificationTap = UITapGestureRecognizer(target: self, action: #selector(ageVerificationTapped))
        let termsOfServiceTap = UITapGestureRecognizer(target: self, action: #selector(termsOfServiceTapped))
        let privacyPolicyTap = UITapGestureRecognizer(target: self, action: #selector(privacyPolicyTapped))
        let thirdPartySharingTap = UITapGestureRecognizer(target: self, action: #selector(thirdPartySharingTapped))
        let locationBasedServiceConsentTap = UITapGestureRecognizer(target: self, action: #selector(locationBasedServiceTapped))
        let marketingTap = UITapGestureRecognizer(target: self, action: #selector(marketingTapped))
        
        agreeAllButton.addGestureRecognizer(agreeAllTap)
        ageVerificationButton.addGestureRecognizer(ageVerificationTap)
        termsOfServiceButton.addGestureRecognizer(termsOfServiceTap)
        privacyPolicyButton.addGestureRecognizer(privacyPolicyTap)
        thirdPartySharingButton.addGestureRecognizer(thirdPartySharingTap)
        locationBasedServiceConsentButton.addGestureRecognizer(locationBasedServiceConsentTap)
        marketingButton.addGestureRecognizer(marketingTap)
    }
    
    private func setupButtons() {
        joinNextButton.layer.cornerRadius = 12
        joinNextButton.isEnabled = false
        joinNextButton.alpha = joinNextButton.isEnabled ? 1.0 : 0.5
        
        let boldFont = UIFont.boldSystemFont(ofSize: 25)
        let attributeTitle = NSAttributedString(
            string: joinNextButton.title(for: .normal) ?? "다음",
            attributes: [NSAttributedString.Key.font: boldFont]
        )
        
        joinNextButton.setAttributedTitle(attributeTitle, for: .normal)
        joinNextButton.setAttributedTitle(attributeTitle, for: .highlighted)
        joinNextButton.setAttributedTitle(attributeTitle, for: .selected)
    }
    
    @IBAction func tappedBackButton(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func backLeftGesture(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func tappedAgreeButton(_ sender: UIButton) {
        isAgreeAll = !isAgreeAll
        setAllAgreements(to: isAgreeAll)
    }
    
    @IBAction func tappedAgeVerificationButton(_ sender: UIButton) {
        toggleAgreement(.ageVerification)
    }
    
    @IBAction func tappedTermsOfServiceAgreeButton(_ sender: UIButton) {
        toggleAgreement(.termsOfService)
    }
    
    @IBAction func tappedPrivacyPoliceAgreeButton(_ sender: UIButton) {
        toggleAgreement(.privacyPolicy)
    }
    
    @IBAction func tappedThirdPartySharingAgreeButton(_ sender: UIButton) {
        toggleAgreement(.thirdPartySharing)
    }
    
    @IBAction func tappedLocationBasedServiceConsentAgreeButton(_ sender: UIButton) {
        toggleAgreement(.locationBasedServiceConsent)
    }
    
    @IBAction func tappedMarketingConsentAgreeButton(_ sender: UIButton) {
        toggleAgreement(.marketingConsent)
    }
    
    @IBAction func tappedTermsOfServiceButton(_ sender: UIButton) {
        moveToTermsOfServiceView()
    }
    
    @IBAction func tappedPrivacyPoliceButton(_ sender: UIButton) {
        moveToPrivacyPoliceView()
    }
    
    @IBAction func tappedThirdPartySharingButton(_ sender: UIButton) {
        moveToThirdPartySharingView()
    }
    
    @IBAction func tappedLocationBasedServiceButton(_ sender: UIButton) {
        moveToLocationBasedServiceConsentView()
    }
    
    @IBAction func tappedMarketingConsentButton(_ sender: UIButton) {
        moveToMarketingConsentView()
    }
    
    @objc private func agreeAllTapped() {
        isAgreeAll = !isAgreeAll
        setAllAgreements(to: isAgreeAll)
    }
    
    @objc private func ageVerificationTapped() {
        toggleAgreement(.ageVerification)
    }
    
    @objc private func termsOfServiceTapped() {
        toggleAgreement(.termsOfService)
    }
    
    @objc private func privacyPolicyTapped() {
        toggleAgreement(.privacyPolicy)
    }
    
    @objc private func thirdPartySharingTapped() {
        toggleAgreement(.thirdPartySharing)
    }
    
    @objc private func locationBasedServiceTapped() {
        toggleAgreement(.locationBasedServiceConsent)
    }
    
    @objc private func marketingTapped() {
        toggleAgreement(.marketingConsent)
    }
    
    @IBAction func tappedJoinNextButton(_ sender: UIButton) {
        proceedToNextStep()
    }
    
}

extension TermsOfUseViewController {
    
    // MARK: - Agreement Management
    private func toggleAgreement(_ type: AgreementType) {
        agreements[type] = !(agreements[type] ?? false)
        updateCheckbox(for: type)
        updateAgreeAllStatus()
        updateJoinNextButtonState()
    }
    
    private func updateCheckbox(for type: AgreementType) {
        let isAgreed = agreements[type] ?? false
        let image = isAgreed ? checkOnImage : checkOffImage
        
        switch type {
        case .ageVerification:
            ageVerificationButton.image = image
        case .termsOfService:
            termsOfServiceButton.image = image
        case .privacyPolicy:
            privacyPolicyButton.image = image
        case .thirdPartySharing:
            thirdPartySharingButton.image = image
        case .locationBasedServiceConsent:
            locationBasedServiceConsentButton.image = image
        case .marketingConsent:
            marketingButton.image = image
        }
    }
    
    private func updateAllCheckboxes() {
        for type in AgreementType.allCases {
            updateCheckbox(for: type)
        }
        updateAgreeAllButton()
    }
    
    private func updateAgreeAllButton() {
        agreeAllButton.image = isAgreeAll ? checkOnImage : checkOffImage
    }
    
    private func updateAgreeAllStatus() {
        isAgreeAll = AgreementType.allCases.allSatisfy { agreements[$0] == true }
    }
    
    private func setAllAgreements(to value: Bool) {
        for type in AgreementType.allCases {
            agreements[type] = value
        }
        isAgreeAll = value
        updateAllCheckboxes()
        updateJoinNextButtonState()
    }
    
    private func areRequiredAgreementsComplete() -> Bool {
        return AgreementType.allCases
            .filter { $0.isRequired }
            .allSatisfy { agreements[$0] == true }
    }
    
    private func updateJoinNextButtonState() {
        joinNextButton.isEnabled = areRequiredAgreementsComplete()
        joinNextButton.alpha = joinNextButton.isEnabled ? 1.0 : 0.5
    }
    
    private func moveToTermsOfServiceView() {
        let JoinTermsOfUseStoryBoard = UIStoryboard(name: "JoinTermsOfUse", bundle: nil)
        if let termsOfServiceViewController = JoinTermsOfUseStoryBoard.instantiateViewController(withIdentifier: "TermsOfServiceView") as? TermsOfServiceViewController {
            termsOfServiceViewController.modalPresentationStyle = .popover
            if let tabBarController = UIApplication.shared.windows.first?.rootViewController as? UITabBarController {
                tabBarController.selectedIndex = 4
                present(termsOfServiceViewController, animated: true)
            }
        }
    }
    
    private func moveToPrivacyPoliceView() {
        let JoinTermsOfUseStoryBoard = UIStoryboard(name: "JoinTermsOfUse", bundle: nil)
        if let privacyPolicyViewController = JoinTermsOfUseStoryBoard.instantiateViewController(withIdentifier: "PrivacyPolicyView") as? PrivacyPolicyViewController {
            privacyPolicyViewController.modalPresentationStyle = .popover
            if let tabBarController = UIApplication.shared.windows.first?.rootViewController as? UITabBarController {
                tabBarController.selectedIndex = 4
                present(privacyPolicyViewController, animated: true)
            }
        }
    }
    
    private func moveToThirdPartySharingView() {
        let JoinTermsOfUseStoryBoard = UIStoryboard(name: "JoinTermsOfUse", bundle: nil)
        if let thirdPartySharingViewController = JoinTermsOfUseStoryBoard.instantiateViewController(withIdentifier: "ThirdPartySharingView") as? ThirdPartySharingViewController {
            thirdPartySharingViewController.modalPresentationStyle = .popover
            if let tabBarController = UIApplication.shared.windows.first?.rootViewController as? UITabBarController {
                tabBarController.selectedIndex = 4
                present(thirdPartySharingViewController, animated: true)
            }
        }
    }
    
    private func moveToLocationBasedServiceConsentView() {
        let JoinTermsOfUseStoryBoard = UIStoryboard(name: "JoinTermsOfUse", bundle: nil)
        if let locationBasedServiceConsentViewController = JoinTermsOfUseStoryBoard.instantiateViewController(withIdentifier: "LocationBasedServiceConsentView") as? LocationBasedServiceConsentViewController {
            locationBasedServiceConsentViewController.modalPresentationStyle = .popover
            if let tabBarController = UIApplication.shared.windows.first?.rootViewController as? UITabBarController {
                tabBarController.selectedIndex = 4
                present(locationBasedServiceConsentViewController, animated: true)
            }
        }
    }
    
    private func moveToMarketingConsentView() {
        let JoinTermsOfUseStoryBoard = UIStoryboard(name: "JoinTermsOfUse", bundle: nil)
        if let marketingConsentViewController = JoinTermsOfUseStoryBoard.instantiateViewController(withIdentifier: "MarketingConsentView") as? MarketingConsentViewController {
            marketingConsentViewController.modalPresentationStyle = .popover
            if let tabBarController = UIApplication.shared.windows.first?.rootViewController as? UITabBarController {
                tabBarController.selectedIndex = 4
                present(marketingConsentViewController, animated: true)
            }
        }
    }
    
    private func proceedToNextStep() {
        if areRequiredAgreementsComplete() {
            delegate?.termsOfUseViewController(self, didAgreeWithTerms: agreements)
            let joinBoard = UIStoryboard(name: "Join", bundle: nil)
            if let joinViewController = joinBoard.instantiateViewController(withIdentifier: "JoinView") as? JoinViewController {
                joinViewController.agreements = self.agreements
                joinViewController.modalPresentationStyle = .fullScreen
                present(joinViewController, animated: true)
                if let tabBarController = UIApplication.shared.windows.first?.rootViewController as? UITabBarController {
                    tabBarController.selectedIndex = 4
                }
            }
            
        } else {
            showTermsOfUseAlert(title: "알림", message: "필수 약관에 모두 동의해주세요.")
        }
    }
    
    private func showTermsOfUseAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
