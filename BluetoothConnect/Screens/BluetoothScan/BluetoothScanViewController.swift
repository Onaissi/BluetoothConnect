//
//  BluetoothScanViewController.swift
//  BluetoothConnect
//
//  Created by Ali Onaissi on 08/10/2023.
//

import UIKit
import Combine

class BluetoothScanViewController: UIViewController {

    @IBOutlet weak var stateImageView: UIImageView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    private var viewModel: BluetoothScanViewModel!
    private var cancellables = [AnyCancellable]()
    
    convenience init(_ viewModel: BluetoothScanViewModel){
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.$labelText
            .receive(on: DispatchQueue.main)
            .map({$0})
            .assign(to: \.text, on: titleLabel)
            .store(in: &cancellables)
        
        viewModel.$actionButtonTitle
            .sink(receiveValue: { [weak self] title in
                self?.actionButton.setTitle(title, for: .normal)
            })
            .store(in: &cancellables)
        
        viewModel.$stateImage
            .sink(receiveValue: { [weak self] image in
                self?.stateImageView.image = image
            })
            .store(in: &cancellables)
        
        viewModel.$shouldShowDeviceList.sink { [weak self] show in
            if show{
                self?.showDeviceList()
            }
        }.store(in: &cancellables)
      
    }


    @IBAction func didClickActionButton(_ sender: Any) {
        if viewModel.currentState == .stopped{
            viewModel.startScanning()
        }else{
            viewModel.stopScanning()
        }
    }
    
    private func showDeviceList(){
        let facade = viewModel.bluetoothFacade
        let viewModel = DeviceListViewModel(bluetoothFacade: facade)
        self.navigationController?.pushViewController(DeviceListViewController(viewModel: viewModel), animated: false)
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


class BluetoothScanViewModel{
    enum ScanState{
        case scanning
        case stopped
    }
    
    let bluetoothFacade: BluetoothFacade
    
    @Published var currentState: ScanState = .stopped
    @Published var shouldShowDeviceList = false
    
    
    @Published var labelText = ""
    @Published var actionButtonTitle = ""
    @Published var stateImage = UIImage(named: "magnifier")
    
    private var cancellables = [AnyCancellable]()
    
    init(bluetoothFacade: BluetoothFacade) {
        self.bluetoothFacade = bluetoothFacade
        
        bluetoothFacade.$isScanning
            .sink { [weak self] isScanning in
                self?.currentState = isScanning ? .scanning : .stopped
            }
            .store(in: &cancellables)
        
        bluetoothFacade.$finishedScanning.sink { [weak self] showResults in
            self?.shouldShowDeviceList = showResults
        }.store(in: &cancellables)
        
        $currentState.sink { [weak self] state in
            if state == .stopped{
                self?.labelText = "scan_for_devices".localized()
                self?.actionButtonTitle = "scan".localized()
                self?.stateImage = UIImage(named: "magnifier")
            }else{
                self?.labelText = "scanning".localized()
                self?.actionButtonTitle = "stop".localized()
                self?.stateImage = UIImage(named: "scanning")
            }
        }.store(in: &cancellables)
    }
    
    func startScanning(){
        bluetoothFacade.scan()
    }
    
    func stopScanning(){
        bluetoothFacade.stopScanning()
    }
    
}
