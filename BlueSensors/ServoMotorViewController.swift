//
//  ServoMotorViewController.swift
//  BlueSensors
//
//  Created by Carlos Duclos on 4/17/18.
//  Copyright © 2018 Carlos Duclos. All rights reserved.
//

import UIKit
import CoreBluetooth

enum MotorPosition: UInt8 {
    case initial = 1, neutral, opened
}

class ServoMotorViewController: UIViewController {
    
    // MARK: - Properties
    
    var currentPosition: MotorPosition = .initial
    var centralManager: CBCentralManager!
    var raspberryPiPeripheral: CBPeripheral?
    var changePositionCharacteristic: CBCharacteristic?
    
    let testServiceUUID = CBUUID(string: "12345678-1234-5678-1234-56789ABCDEF0")
    let changePositionCharacteristicUUID = CBUUID(string: "12345678-1234-5678-1234-56789abcdef1")

    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        centralManager.scanForPeripherals(withServices: nil)
    }
    
    func send(_ position: MotorPosition?) {
        guard let position = position else { return }
        guard let peripheral = raspberryPiPeripheral else { return }
        guard let characteristic = changePositionCharacteristic else { return }
        
        let data = Data(bytes: [position.rawValue])
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
    
    // MARK: - Actions
    
    @IBAction func refreshPressed(_ sender: Any) {
        centralManager.stopScan()
        centralManager.scanForPeripherals(withServices: nil)
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        send(MotorPosition(rawValue: UInt8(sender.tag)))
    }
    
}

extension ServoMotorViewController: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
            
            centralManager.scanForPeripherals(withServices: nil)
        }
        
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral)
        
        guard peripheral.name == "raspberrypi" else { return }
        raspberryPiPeripheral = peripheral
        raspberryPiPeripheral?.delegate = self
        
        centralManager.stopScan()
        centralManager.connect(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        raspberryPiPeripheral?.discoverServices([testServiceUUID])
    }
    
}

extension ServoMotorViewController: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            peripheral.discoverCharacteristics([changePositionCharacteristicUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print(characteristic)
            
            if characteristic.properties.contains(.read) {
                print("\(characteristic.uuid): properties contains .read")
            }
            if characteristic.properties.contains(.notify) {
                print("\(characteristic.uuid): properties contains .notify")
            }
            if characteristic.properties.contains(.write) {
                print("\(characteristic.uuid): properties contains .write")
            }
            
            changePositionCharacteristic = characteristic
        }
    }
    
}
