//
//  BluetoothFacade.swift
//  BluetoothConnect
//
//  Created by Ali Onaissi on 08/10/2023.
//

import Foundation
import CoreBluetooth
import Combine

class BluetoothFacade{

    private let bluetoothManager: BluetoothManager
    
    private let scanTime = TimeInterval(15) // Scan time in seconds
    
    private var timer: Timer?
    
    @Published public private(set) var connectedPeripherals = Set<PeripheralAdapter>()
    @Published public private(set) var peripherals = Set<PeripheralAdapter>()
    @Published public private(set) var bluetoothConnected = false
    @Published public private(set) var isScanning = false
    @Published public private(set) var finishedScanning = false
    
     
    init(bluetoothManager: BluetoothManager) {
        self.bluetoothManager = bluetoothManager
        self.bluetoothManager.centralManagerDelegate = self
        self.bluetoothManager.peripheralDelegate = self
    }
    
    func scan(){
        isScanning = true
        peripherals = []
        bluetoothManager.startScanning()
        timer = Timer.scheduledTimer(withTimeInterval: scanTime, repeats: false, block: { [weak self]  _ in
            self?.stopScanning()
            self?.finishedScanning = true
        })
    }
    
    
    func stopScanning(){
        isScanning = false
        bluetoothManager.stopScanning()
        resetTimer()
    }
    
    func connect(to peripheral: CBPeripheral){
        bluetoothManager.connect(peripheral)
    }
    
    func disconnect(from peripheral: CBPeripheral){
        bluetoothManager.disconnet(peripheral)
    }
    
    fileprivate func resetTimer(){
        timer?.invalidate()
        timer = nil
    }
    
}



extension BluetoothFacade: CentralManagerDelegate{
    func stateUpdated(_ centralManager: CBCentralManager) {
        if centralManager.state == .poweredOn{
            bluetoothConnected = true
            return
        }
        isScanning = false
        bluetoothConnected = false
        resetTimer()
    }
}

extension BluetoothFacade: PripheralDelegate{
    func peripheralFound(_ peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let peri = PeripheralAdapter(peripheral: peripheral)
        peripherals.insert(peri)
    }
    
    func peripheralConnected(_ peripheral: CBPeripheral) {
        let peri = PeripheralAdapter(peripheral: peripheral)
        connectedPeripherals.insert(peri)
        replacePeripheral(peripheral)
    }
    
    func replacePeripheral(_ peripheral: CBPeripheral){
        if var timedPeripheral = peripherals.first(where: {$0.currentPeripheral.identifier == peripheral.identifier}){
            timedPeripheral.replace(by: peripheral)
            peripherals.update(with: timedPeripheral)
        }
    }
    
    func peripheralDisconnected(_ peripheral: CBPeripheral) {
        connectedPeripherals.remove(PeripheralAdapter(peripheral: peripheral))
        replacePeripheral(peripheral)
    }
    
    func failedToConnect(_ peripheral: CBPeripheral) {
        print("Failed to connect")
        replacePeripheral(peripheral)
    }
    
    func reset() {
        peripherals = []
        connectedPeripherals = []
        finishedScanning = false
        resetTimer()
    }
    
    func servicesUpdated(_ peripheral: CBPeripheral) {
        print("Service updated")
        replacePeripheral(peripheral)
        
    }
    
    func characteristicsUpdated(_ peripheral: CBPeripheral) {
        print("characteristics updated")
        replacePeripheral(peripheral)
    }
    
    func nameUpdated(_ peripheral: CBPeripheral) {
        print("Name updated")
        replacePeripheral(peripheral)
    }
    
    
}
