//
//  DataViewController.swift
//  SensorDataCollector
//
//  Created by baixg on 2019/1/14.
//  Copyright © 2019 baixg. All rights reserved.
//

import UIKit

class DataViewController: UITableViewController {
    
    var refreshTimer : Timer!
    var sensorNameList : [String] = []
    var sensorValueList : [String] = []
    let dataProcessing = DataProcessing.init()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        if self.canBecomeFirstResponder {
            self.becomeFirstResponder()
        }
    }
    
    @IBAction func startCollectData(_ sender: Any) {
        if refreshTimer != nil{
            refreshTimer.fire()
        }
        else{
            self.dataProcessing.sensorCollector.startCollectSensorData()
            refreshTimer = Timer.scheduledTimer(withTimeInterval: 6, repeats: true, block: { (refreshTimer) in
                (self.sensorNameList, self.sensorValueList) = self.dataProcessing.updateData()
                if self.sensorNameList.count != self.sensorValueList.count{
                    print("Error occurs.")
                    self.sensorNameList = []
                    self.sensorValueList = []
                    /*
                     refreshTimer = Timer.init(timeInterval: 6, repeats: true, block: { (refreshTimer) in
                     (self.sensorNameList, self.sensorValueList) = self.dataProcessing.updateData()
                     if self.sensorNameList.count != self.sensorValueList.count{
                     print("Error occurs.")
                     self.sensorNameList = []
                     self.sensorValueList = []
                     }
                     //                self.tableView.reloadData()
                     })
                     RunLoop.main.add(refreshTimer, forMode: RunLoop.Mode.default)*/
                }
                self.tableView.reloadData()
            })
            
        }
    }
    
    @IBAction func stopCollectData(_ sender: Any) {
        self.dataProcessing.sensorCollector.stopCollectSensorData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sensorNameList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .value1, reuseIdentifier: "SensorDataCell")
        if indexPath.row < sensorNameList.count{
            cell.textLabel?.text = sensorNameList[indexPath.row]
            cell.detailTextLabel?.text = sensorValueList[indexPath.row]
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.endEditing(true)
    }
    
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        self.dataProcessing.sensorCollector.setShakeStatus(status: "ShakeBegan", sensorData: self.dataProcessing.data)

    }
    
    override func motionCancelled(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        self.dataProcessing.sensorCollector.setShakeStatus(status: "ShakeCancelled", sensorData: self.dataProcessing.data)

    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        self.dataProcessing.sensorCollector.setShakeStatus(status: "ShakeEnded", sensorData: self.dataProcessing.data)
        self.dataProcessing.sensorCollector.setShakeTimes(time: 1, sensorData: self.dataProcessing.data)
    }



}
