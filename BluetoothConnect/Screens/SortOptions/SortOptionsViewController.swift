//
//  SortOptionsViewController.swift
//  BluetoothConnect
//
//  Created by Ali Onaissi on 10/10/2023.
//

import UIKit
import Combine

class SortOptionsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var viewModel: SortOptionsViewModel!
    private let cellIdentifier = "option_cell"
    private var subscripers = [AnyCancellable]()
    
    convenience init(viewModel: SortOptionsViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        viewModel.$selectedOption
            .receive(on: DispatchQueue.main)
            .sink { _ in
            self.tableView.reloadData()
        }.store(in: &subscripers)
    
    }

}

extension SortOptionsViewController: UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfOptions()
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        let option = viewModel.optionItemAt(indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = option.description()

        if viewModel.selectedOption.description() == option.description(){
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectOption(at: indexPath)
        self.navigationController?.popViewController(animated: true)
    }
}

class SortOptionsViewModel{
    var options = [DeviceSortable]()
    @Published var selectedOption: DeviceSortable
    
    private var deviceListViewModel: DeviceListViewModel
    
    init(deviceListViewModel: DeviceListViewModel, selectedOption: DeviceSortable? = nil) {
        self.deviceListViewModel = deviceListViewModel
        
        self.options = [
            AlphabeticalSort(isAscending: true),
            AlphabeticalSort(isAscending: false),
            MacSort(),
            ScanTimeSort()
        ]
        
        self.selectedOption = selectedOption ?? options.first!
    }
    
    func numberOfSections() -> Int{
        return 1
    }
    
    func numberOfOptions() -> Int{
        return options.count
    }
    
    func optionItemAt(_ indexPath: IndexPath) -> DeviceSortable{
        return options[indexPath.row]
    }
    
    func selectOption(at indexPath: IndexPath){
        self.selectedOption = optionItemAt(indexPath)
        deviceListViewModel.setSortable(selectedOption)
    }
    
    
}
