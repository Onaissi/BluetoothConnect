//
//  BluetoothManager.swift
//  BluetoothConnect
//
//  Created by Ali Onaissi on 07/10/2023.
//

import Foundation
import CoreBluetooth
import Combine

protocol CentralManagerDelegate: AnyObject{
    func stateUpdated(_ centralManager: CBCentralManager)
    
}

protocol PripheralDelegate: AnyObject{
    func peripheralFound(_ peripheral : CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
    func peripheralConnected(_ peripheral: CBPeripheral)
    func peripheralDisconnected(_ peripheral: CBPeripheral)
    func failedToConnect(_ peripheral: CBPeripheral)
    
    func reset()
    
    func servicesUpdated(_ peripheral: CBPeripheral)
    func characteristicsUpdated(_ peripheral: CBPeripheral)
    func nameUpdated(_ peripheral: CBPeripheral)
    
}

class BluetoothManager: NSObject{
    
    private let centralManager: CBCentralManager
    
    
    weak var centralManagerDelegate: CentralManagerDelegate?
    weak var peripheralDelegate: PripheralDelegate?
    
    init(_ centralManager: CBCentralManager){
        self.centralManager = centralManager
        super.init()
        self.centralManager.delegate = self
    }
    
    func startScanning(){
        if centralManager.state == .poweredOn, !centralManager.isScanning{
            centralManager.scanForPeripherals(withServices: nil)
        }
    }
    
    func stopScanning(){
        if centralManager.isScanning{
            centralManager.stopScan()
        }
    }
    
    func connect(_ peripheral: CBPeripheral){
        peripheral.delegate = self
        centralManager.connect(peripheral)
    }
    
    func disconnet(_ peripheral: CBPeripheral){
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    fileprivate func reset(){
        stopScanning()
        peripheralDelegate?.reset()
    }
    
}

extension BluetoothManager: CBCentralManagerDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state{
        case .poweredOn: startScanning()
        case .poweredOff: reset()
        default: //.unauthorized, .unknown, .unsupported, .resetting:
            reset()
            print("Bluetooth connnection lost")
        }
        centralManagerDelegate?.stateUpdated(central)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("found new device")
        peripheralDelegate?.peripheralFound(peripheral, advertisementData: advertisementData, rssi: RSSI)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        peripheralDelegate?.peripheralDisconnected(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheralDelegate?.peripheralDisconnected(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        peripheralDelegate?.failedToConnect(peripheral)
    }
}


extension BluetoothManager: CBPeripheralDelegate{
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services ?? []{
            peripheral.discoverCharacteristics(nil, for: service)
        }
        
        peripheralDelegate?.servicesUpdated(peripheral)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics ?? []{
            peripheral.discoverDescriptors(for: characteristic)
        }
        peripheralDelegate?.characteristicsUpdated(peripheral)
    }
    
    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        peripheralDelegate?.nameUpdated(peripheral)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        peripheralDelegate?.characteristicsUpdated(peripheral)
    }
}
