//
//  UIProperties.swift
//  Instories
//
//  Created by Vladyslav Yakovlev on 19.08.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

enum UIProperties {
    
    static let iPhoneXTopInset: CGFloat = 32
    
    static var userCellHeight: CGFloat {
        switch currentDevice {
        case .iPhone5 : return 74
        default : return 76
        }
    }
}
