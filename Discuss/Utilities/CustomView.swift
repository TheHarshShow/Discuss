//
//  CustomView.swift
//  Discuss
//
//  Created by Harsh Motwani on 16/04/20.
//  Copyright © 2020 Harsh Motwani. All rights reserved.
//

import UIKit

class CustomView: UIView {

    // this is needed so that the inputAccesoryView is properly sized from the auto layout constraints
    // actual value is not important

    override var intrinsicContentSize: CGSize {
        return CGSize.zero
    }
}
