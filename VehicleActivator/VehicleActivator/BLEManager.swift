//
//  BLEManager.swift
//  VehicleActivator
//
//  Created by user222240 on 7/7/22.
//

import Foundation
import CoreBluetooth

struct Peripheral: Identifiable {
    let id: Int
    let name: String
    //let uuid: UUID
    let rssi: Int
}

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate {
    
    var myCentral: CBCentralManager!
    @Published var isSwitchedOn = false
    @Published var peripherals = [Peripheral]()
    
    override init() {
        super.init()
         
        myCentral = CBCentralManager(delegate: self, queue: nil)
        myCentral.delegate = self
    }


    func centralManagerDidUpdateState(_ central: CBCentralManager) {
         if central.state == .poweredOn {
             isSwitchedOn = true
         }
         else {
             isSwitchedOn = false
         }
    }


    /**
     * CBCentralManagerDelegate callback method didDiscover
     */
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        var peripheralName: String!
        var uuidString: String!
       
        if let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            peripheralName = name
        }
        else {
            peripheralName = "Unknown"
        }
        
        if let uuidsKey = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? String {
            uuidString = uuidsKey
        }
        else {
            uuidString = "Unknown"
        }
        
        //let newPeripheral = Peripheral(id: peripherals.count, name: peripheralName, uuid: UUID(uuidString: uuidString)!, rssi: RSSI.intValue)
        let newPeripheral = Peripheral(id: peripherals.count, name: peripheralName, rssi: RSSI.intValue)
        print(newPeripheral)
        peripherals.append(newPeripheral)
    }
    
    /**
     * Once connection is established, the centralManager didConnect delegate method gets called
     */
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        //Here we can activate peripheral - Arduino
        //self.myPeripheral.discoverServices(nil)
    }
    
    func startScanning() {
         print("startScanning")
        //withService nil we are performing broad-based scan
        //WITHSERVICE SERVICEUUIDS: [CBUUID] allows scan specific peripheral
        //For every peripheral found, the CBCentralManagerDelegate callback method didDiscover peripheral get called
         myCentral.scanForPeripherals(withServices: nil, options: nil)
     }
    
    func stopScanning() {
        print("stopScanning")
        myCentral.stopScan()
    }
    
    func connectWithPeripheral(peripheral: CBPeripheral) {
        //Connect with the BLE
        self.myCentral.connect(peripheral, options: nil)
    }
}
