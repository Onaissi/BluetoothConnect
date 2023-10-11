//
//  DeviceSortable.swift
//  BluetoothConnect
//
//  Created by Ali Onaissi on 10/10/2023.
//

import Foundation
import CoreBluetooth

protocol DeviceSortable{
    func description() -> String
    func sort(_ arr: [PeripheralAdapter]) -> [PeripheralAdapter]
}



struct AlphabeticalSort: DeviceSortable{
    var isAscending: Bool = true
    
    private var compareFunc: (PeripheralAdapter, PeripheralAdapter) -> Bool {
        if isAscending{
            return {$0.currentPeripheral.name ?? "~" < $1.currentPeripheral.name ?? "~"}
        }
        return {$0.currentPeripheral.name ?? "~" > $1.currentPeripheral.name ?? "~"}
    }
    
    func sort(_ arr: [PeripheralAdapter]) -> [PeripheralAdapter] {
        return arr.sorted(by: compareFunc)
    }
    
    func description() -> String{
        return String(format: "name_sort".localized(), isAscending ? "ASC" : "DSC")
    }
}

struct MacSort: DeviceSortable{
    func sort(_ arr: [PeripheralAdapter]) -> [PeripheralAdapter] {
        return arr.sorted(by: {$0.currentPeripheral.identifier.uuidString < $1.currentPeripheral.identifier.uuidString })
    }
    
    func description() -> String{
        return "mac_address_asc".localized()
    }
}

// TODO: update it
struct ScanTimeSort: DeviceSortable{
    func sort(_ arr: [PeripheralAdapter]) -> [PeripheralAdapter] {
        return arr.sorted(by: {$0.timestamp < $1.timestamp })
    }
    
    func description() -> String{
        return "scan_time".localized()
    }
}



