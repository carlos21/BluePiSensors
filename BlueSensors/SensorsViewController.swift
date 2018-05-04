//
//  SensorsViewController.swift
//  BlueSensors
//
//  Created by Carlos Duclos on 5/3/18.
//  Copyright © 2018 Carlos Duclos. All rights reserved.
//

import UIKit

final class SensorsViewController: UITableViewController {
    
    enum Sensor {
        case servoMotor, DHT11, DHT22
        
        var title: String {
            switch self {
            case .servoMotor: return "Servo Motor"
            case .DHT11: return "DHT11"
            case .DHT22: return "DHT22"
            }
        }
        
        var segueIdentifier: String {
            switch self {
            case .servoMotor: return "showServoMotor"
            case .DHT22, .DHT11: return "showTemperature"
            }
        }
    }
    
    // MARK: - Properties
    
    let cellIdentifier = "sensorCell"
    var sensors: [Sensor] = [.servoMotor, .DHT22]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - UITableView
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sensors.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sensor = sensors[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        cell?.textLabel?.text = sensor.title
        return cell ?? UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sensor = sensors[indexPath.row]
        performSegue(withIdentifier: sensor.segueIdentifier, sender: self)
    }
    
}
