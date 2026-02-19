//
//  TermsOfUseViewControllerDelegates.swift
//  5GCAMP
//
//  Created by WONJI HA on 3/10/25.
//

import Foundation

protocol TermsOfUseViewControllerDelegates: AnyObject {
    func termsOfUseViewController(_ viewController: TermsOfUseViewController, didAgreeWithTerms agreements: [AgreementType: Bool])
}
