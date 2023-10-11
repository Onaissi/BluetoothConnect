//
//  Peripheral.swift
//  BluetoothConnect
//
//  Created by Ali Onaissi on 11/10/2023.
//

import Foundation
import CoreBluetooth

protocol Peripheral{
    var timestamp: Date {get}
}

struct PeripheralAdapter: Peripheral, Equatable, Hashable{
    private(set) var timestamp: Date
    
    private(set) var currentPeripheral: CBPeripheral
    
    init(peripheral: CBPeripheral) {
        self.timestamp = Date()
        self.currentPeripheral = peripheral
    }
    
    mutating func replace(by peripheral: CBPeripheral){
        self.currentPeripheral = peripheral
    }
    
    
    static func ==(lhs: PeripheralAdapter, rhs: PeripheralAdapter) -> Bool{
        return lhs.currentPeripheral == rhs.currentPeripheral
    }
    
    func hash(into hasher: inout Hasher) {
        self.currentPeripheral.hash(into: &hasher)
    }
}
