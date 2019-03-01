//
//  Fonts.swift
//  Instories
//
//  Created by Vladyslav Yakovlev on 06.08.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

enum Fonts {
    
    static let billabong = "Billabong"
    
    static let circeBold = "Circe-Bold"
    
    static var topBar: UIFont {
        return UIFont(name: Fonts.billabong, size: 42)!
    }
    
    static var userCellFont: UIFont {
        switch currentDevice {
        case .iPhone5 : return UIFont(name: Fonts.circeBold, size: 20)!
        default : return UIFont(name: Fonts.circeBold, size: 21)!
        }
    }
    
    static var searchBarFont: UIFont {
        switch currentDevice {
        case .iPhone5 : return UIFont(name: Fonts.circeBold, size: 20)!
        default : return UIFont(name: Fonts.circeBold, size: 21)!
        }
    }
}
