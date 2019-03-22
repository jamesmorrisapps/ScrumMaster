//
//  UIButtonExt.swift
//  scrum-master
//
//  Created by James B Morris on 5/25/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import UIKit

extension UIButton {
    func setSelectedColor() {
        self.backgroundColor = #colorLiteral(red: 0.4902461171, green: 0.845179975, blue: 0.4616821408, alpha: 1)
    }
    
    func setDeselectedColor() {
        self.backgroundColor = #colorLiteral(red: 0.6980392157, green: 0.8666666667, blue: 0.6862745098, alpha: 1)
    }
}
