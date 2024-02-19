//
//  Extensions.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 2/17/24.
//

import Foundation
import UIKit

extension UINavigationController {
    
    // MARK: Back Button Minimalism
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        navigationBar.topItem?.backButtonDisplayMode = .minimal
    }
}
