//
//  TermsOfUseViewModel.swift
//  5GCAMP
//
//  Created by WONJI HA on 3/10/25.
//

import Foundation

// MARK: - 이용약관 동의 상태에 따라 회원가입 URL 생성
enum AgreementType: CaseIterable {
    case ageVerification
    case termsOfService
    case privacyPolicy
    case thirdPartySharing
    case locationBasedServiceConsent
    case marketingConsent
    
    /// 웹 요청 파라미터 이름
    var parameterName: String {
        switch self {
        case .ageVerification:
            return "agreecheckbox1"
        case .termsOfService:
            return "agreecheckbox2"
        case .privacyPolicy:
            return "agreecheckbox3"
        case .thirdPartySharing:
            return "agreecheckbox4"
        case .locationBasedServiceConsent:
            return "agreecheckbox5"
        case .marketingConsent:
            return "agreecheckbox6"
        }
    }
    
    /// 필수 약관 여부
    var isRequired: Bool {
        switch self {
        case .marketingConsent:
            return false
        default:
            return true
        }
    }
}
