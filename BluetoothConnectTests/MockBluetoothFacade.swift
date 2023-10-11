//
//  MockBluetoothFacade.swift
//  BluetoothConnectTests
//
//  Created by Ali Onaissi on 11/10/2023.
//

import Foundation
import CoreBluetooth
@testable import BluetoothConnect

final class MockBluetoothFacade: BluetoothFacade{
    
    var scanCalled = false
    var scanStopped = false
    var deviceConnected = false
    var deviceDisconnected = false
    
    init(){
        super.init(bluetoothManager: BluetoothManager(CBCentralManager()))
    }
    
    override func scan(){
     
        scanCalled = true
    }
    
    
    override func stopScanning(){
     
        scanStopped = true
    }
    
    override func connect(to peripheral: CBPeripheral){
            deviceConnected = true
    }
    
    override func disconnect(from peripheral: CBPeripheral){
            deviceDisconnected = true
    }
}
