//
//  ShowDeviceViewController.swift
//  BluetoothConnect
//
//  Created by Ali Onaissi on 09/10/2023.
//

import UIKit
import CoreBluetooth
import Combine

class ShowDeviceViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var macLabel: UILabel!
    @IBOutlet weak var deviceTitleLabel: UILabel!
    
    
    private var viewModel: ShowDeviceViewModel!
    private var cancellables = [AnyCancellable]()
    
    convenience init(viewModel: ShowDeviceViewModel){
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "device_cell")
        
        viewModel.$peripheral
            .receive(on: DispatchQueue.main)
            .map({$0.name})
            .assign(to: \.text, on: deviceTitleLabel)
            .store(in: &cancellables)
        
        viewModel.$peripheral
            .receive(on: DispatchQueue.main)
            .map({$0.identifier.uuidString})
            .assign(to: \.text, on: macLabel)
            .store(in: &cancellables)
        
        viewModel.$peripheral
            .receive(on: DispatchQueue.main)
            .map({$0.state == .connected ? "connected".localized() : "disconnected".localized()})
            .assign(to: \.text, on: statusLabel)
            .store(in: &cancellables)
        
        viewModel.$peripheral.sink { [weak self] _ in
            self?.tableView.reloadData()
        }.store(in: &cancellables)
       
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ShowDeviceViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "device_cell", for: indexPath)
        
        guard let characteristic = viewModel.characteristicForCell(indexPath) else{
            return cell
        }
        var content = cell.defaultContentConfiguration()
        content.text = characteristic.properties.readableValue
        content.secondaryText = characteristic.descriptors?.reduce("descriptors".localized(), {$0.appending(" \($1.uuid.uuidString)")})
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.titleForSection(section)
    }
    
}


class ShowDeviceViewModel{
    enum Sections: Int{
        case services = 0
        case characteristics
        case descriptors
    }
    let bluetoothFacade: BluetoothFacade
    
    @Published var peripheral: CBPeripheral
    
    private var cancellables = [AnyCancellable]()
    
    init(bluetoothFacade: BluetoothFacade, peripheral: CBPeripheral) {
        self.bluetoothFacade = bluetoothFacade
        self.peripheral = peripheral
        self.peripheral.discoverServices(nil)
       
        bluetoothFacade.$peripherals.sink { [weak self] peripheralSet in
            if let peripheral = peripheralSet.first(where: {$0.currentPeripheral == peripheral}){
                self?.peripheral = peripheral.currentPeripheral
            }
        }.store(in: &cancellables)
    }
    
    func numberOfSections() -> Int{
        return peripheral.services?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int{
        guard let services = peripheral.services, section < services.count else{
            return 0
        }
        let characteristcs = services[section].characteristics
        return characteristcs?.count ?? 0
    }
    
    func characteristicForCell(_ indexPath: IndexPath) -> CBCharacteristic?{
        guard let services = peripheral.services, indexPath.section < services.count else{
            return nil
        }
        return services[indexPath.section].characteristics?[indexPath.row]
    }
    

    func titleForSection(_ section: Int) -> String?{
        let service = peripheral.services?[section]
        return "service".localized().appending(service?.uuid.uuidString ?? "")
    }
    
    
    
    
    
}
