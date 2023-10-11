//
//  String+extension.swift
//  BluetoothConnect
//
//  Created by Ali Onaissi on 08/10/2023.
//

import Foundation

extension String{
    func localized(_ comment: String = "") -> String{
        return NSLocalizedString(self, comment: comment)
    }
}
