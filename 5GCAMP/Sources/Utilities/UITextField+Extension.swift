//
//  UITextField+Extension.swift
//  5GCAMP
//
//  Created by Wonji Ha on 3/13/25.
//

import UIKit

extension UITextField {
    func setPlacheholderColor(_ color: UIColor) {
        attributedPlaceholder = NSAttributedString(
            string: placeholder ?? "",
            attributes: [.foregroundColor: color]
        )
    }
}
