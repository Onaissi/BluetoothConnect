//
//  DeviceListViewController.swift
//  BluetoothConnect
//
//  Created by Ali Onaissi on 09/10/2023.
//

import UIKit
import Combine
import CoreBluetooth

class DeviceListViewController: UIViewController {

    private var viewModel: DeviceListViewModel!
    private var cancellables = [AnyCancellable]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DeviceTableViewCell.registerCell(in: tableView)
        tableView.rowHeight = 100
        tableView.dataSource = self
        tableView.delegate = self
        
        let sortButton = UIBarButtonItem(title: "sort_title".localized(), style: .plain, target: self, action: #selector(didClickSortButton))
        self.navigationItem.rightBarButtonItem = sortButton
        
        viewModel.$peripherals.sink { [weak self] _ in
            self?.tableView.reloadData()
        }.store(in: &cancellables)
    }

    convenience init(viewModel: DeviceListViewModel!) {
        self.init()
        self.viewModel = viewModel
    }
    
    @objc func didClickSortButton(){
        let sortViewModel = SortOptionsViewModel(deviceListViewModel: self.viewModel, selectedOption: viewModel.currentSortable)
        let sortViewController = SortOptionsViewController(viewModel: sortViewModel)
        self.navigationController?.pushViewController(sortViewController, animated: true)
    }

}




extension DeviceListViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfDevices()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DeviceTableViewCell.cellIdentifier, for: indexPath) as! DeviceTableViewCell
        
        let peripheral = viewModel.deviceAt(indexPath)
        cell.render(with: peripheral.currentPeripheral)
        cell.onValueChange = { [weak self] isOn in
            if isOn{
                self?.viewModel.connect(peripheral.currentPeripheral)
            }else{
                self?.viewModel.disconnect(peripheral.currentPeripheral)
            }
        }
        return cell
    }
    
    
}



extension DeviceListViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let peripheral = viewModel.deviceAt(indexPath)
        if peripheral.currentPeripheral.state == .connected {
            showDetails(peripheral.currentPeripheral)
        }
        
    }
    
    func showDetails(_ periphral: CBPeripheral){
        let showDeviceViewModel = ShowDeviceViewModel(bluetoothFacade: viewModel.bluetoothFacade, peripheral: periphral)
        let viewController = ShowDeviceViewController(viewModel: showDeviceViewModel)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}




class  DeviceListViewModel{
    let bluetoothFacade: BluetoothFacade
    
    @Published var peripherals = [PeripheralAdapter]()
    
    private var cancellables = [AnyCancellable]()
    
    fileprivate var currentSortable: DeviceSortable = AlphabeticalSort(isAscending: true)
    
    init(bluetoothFacade: BluetoothFacade) {
        self.bluetoothFacade = bluetoothFacade
        
        bluetoothFacade.$peripherals.sink { [weak self] peripheralSet in
            self?.sort(Array(peripheralSet))
        }.store(in: &cancellables)
    }
    
    func sort(_ peripherals: [PeripheralAdapter]){
        let sortedArray = currentSortable.sort(peripherals)
        self.peripherals = sortedArray
    }
    
    func numberOfSections() -> Int{
        return 1
    }
    
    func numberOfDevices() -> Int{
        return peripherals.count
    }
    
    func deviceAt(_ indexPath: IndexPath) -> PeripheralAdapter{
        return peripherals[indexPath.row]
    }
    
    
    func connect(_ peripheral: CBPeripheral){
        bluetoothFacade.connect(to: peripheral)
    }
    
    func disconnect(_ peripheral: CBPeripheral){
        bluetoothFacade.disconnect(from: peripheral)
    }
    
    func setSortable(_ sortable: DeviceSortable){
        self.currentSortable = sortable
        sort(self.peripherals)
        
    }
    
}
