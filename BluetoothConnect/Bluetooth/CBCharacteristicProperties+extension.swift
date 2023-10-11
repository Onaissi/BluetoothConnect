//
//  CBCharacteristicProperties+extension.swift
//  BluetoothConnect
//
//  Created by Ali Onaissi on 09/10/2023.
//

import Foundation
import CoreBluetooth

extension CBCharacteristicProperties{
    public var readableValue: String{
        var preperties = [String]()
        
        if self.contains(.broadcast) {
            preperties.append("Broadcast")
        }
        if self.contains(.read) {
            preperties.append("Read")
        }
        if self.contains(.writeWithoutResponse) {
            preperties.append("Write Without Response")
        }
        if self.contains(.write) {
            preperties.append("Write")
        }
        if self.contains(.notify) {
            preperties.append("Notify")
        }
        if self.contains(.indicate) {
            preperties.append("Indicate")
        }
        if self.contains(.authenticatedSignedWrites) {
            preperties.append("Authenticated Signed Writes")
        }
        if self.contains(.extendedProperties) {
            preperties.append("Extended Properties")
        }
        if self.contains(.notifyEncryptionRequired) {
            preperties.append("Notify Encryption Required")
        }
        if self.contains(.indicateEncryptionRequired) {
            preperties.append("Indicate Encryption Required")
        }
        return String(preperties.joined(separator: ","))
    }
}
