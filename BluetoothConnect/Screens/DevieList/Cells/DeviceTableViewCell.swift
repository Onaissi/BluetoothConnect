//
//  DeviceTableViewCell.swift
//  BluetoothConnect
//
//  Created by Ali Onaissi on 09/10/2023.
//

import UIKit
import CoreBluetooth

class DeviceTableViewCell: UITableViewCell {

    static let cellIdentifier = "DeviceTableViewCell"
    static let nibName = "DeviceTableViewCell"
    
    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var macLabel: UILabel!
    @IBOutlet weak var connectionSwitch: UISwitch!
    @IBOutlet weak var connectionLabel: UILabel!
    @IBOutlet weak var mainImageView: UIImageView!
    
    var onValueChange: ((Bool) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func render(with peripheral: CBPeripheral){
        mainImageView.image = UIImage(named: "bluetooth")
        macLabel.text = peripheral.identifier.uuidString
        mainTitleLabel.text = peripheral.name ?? "- "
        self.accessoryType = .none
        connectionSwitch.isOn = false
        self.connectionSwitch.isEnabled = true
        if peripheral.state == .connected{
            connectionLabel.text = "connected".localized()
            self.accessoryType = .disclosureIndicator
            self.connectionSwitch.isOn = true
        }else if peripheral.state == .connecting{
            connectionLabel.text = "connecting".localized()
            self.connectionSwitch.isEnabled = false
        }else{
            connectionLabel.text = "disconnected".localized()
        }
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        if let onValueChange = onValueChange{
            onValueChange(sender.isOn)
        }
    }
    
    class func registerCell(in tableView: UITableView){
        let nib = UINib(nibName: nibName, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellIdentifier)
    }
}
