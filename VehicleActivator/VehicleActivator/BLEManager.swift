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
    let cbPeripheral: CBPeripheral
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

    func startScanning() {
         print("startScanning")
        peripherals.removeAll()
        //withService nil we are performing broad-based scan
        //WITHSERVICE SERVICEUUIDS: [CBUUID] allows scan specific peripheral
        //For every peripheral found, the CBCentralManagerDelegate callback method didDiscover peripheral get called
         myCentral.scanForPeripherals(withServices: nil, options: nil)
     }
    
    func stopScanning() {
        print("stopScanning")
        peripherals.removeAll()
        myCentral.stopScan()
    }
    
    func connectWithPeripheral(peripheral: CBPeripheral) {
        //Connect with the BLE
        self.myCentral.connect(peripheral, options: nil)
    }
    
    /**
     * CBCentralManagerDelegate callback method didDiscover
     */
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        var peripheralName: String!
        //var uuidString: String!
       
        if let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            peripheralName = name
        }
        else {
            peripheralName = "Unknown"
        }
        
        //if let uuidsKey = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? String {
        //    uuidString = uuidsKey
        //}
        //else {
        //    uuidString = "Unknown"
        //}
        
        //let newPeripheral = Peripheral(id: peripherals.count, name: peripheralName, uuid: UUID(uuidString: uuidString)!, rssi: RSSI.intValue)
        let newPeripheral = Peripheral(id: peripherals.count, name: peripheralName, rssi: RSSI.intValue, cbPeripheral: peripheral)
        print(newPeripheral)
        peripherals.append(newPeripheral)
    }
    
    /**
     * Once connection is established, the centralManager didConnect delegate method gets called
     */
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        //peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    // Call after discovering services
    func discoverCharacteristics(peripheral: CBPeripheral) {
        guard let services = peripheral.services else {
            return
        }
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
       
    // In CBPeripheralDelegate class/extension
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return
        }
        discoverCharacteristics(peripheral: peripheral)
    }
     
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
        // Consider storing important characteristics internally for easy access and equivalency checks later.
        // From here, can read/write to characteristics or subscribe to notifications as desired.
    }
}
