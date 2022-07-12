//
//  BLEManager.swift
//  VehicleActivator
//
//  Created by user222240 on 7/7/22.
//

import Foundation
import CoreBluetooth
//let vehicleServiceCBUUID = CBUUID(string: "0x2A57")

struct Peripheral: Identifiable {
    let id: Int
    let name: String
    //let uuid: UUID
    let rssi: Int
    let cbPeripheral: CBPeripheral
}

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var myCentral: CBCentralManager!
    @Published var isSwitchedOn = false
    @Published var peripherals = [Peripheral]()
    
    override init() {
        super.init()
         
        myCentral = CBCentralManager(delegate: self, queue: nil)
        myCentral.delegate = self
    }


    func centralManagerDidUpdateState(_ central: CBCentralManager) {
         /*if central.state == .poweredOn {
             isSwitchedOn = true
         }
         else {
             isSwitchedOn = false
         }*/
        switch central.state{
            
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .powerOff")
            isSwitchedOn = false
        case .poweredOn:
            print("central.state is .poweredOn")
            isSwitchedOn = true
        @unknown default:
            print("central.state is called by DEFAULT")
        }
    }

    func startScanning() {
         print("startScanning")
        peripherals.removeAll()
        //withService nil we are performing broad-based scan
        //WITHSERVICE SERVICEUUIDS: [CBUUID] allows scan specific peripheral
        //For every peripheral found, the CBCentralManagerDelegate callback method didDiscover peripheral get called
        myCentral.scanForPeripherals(withServices: nil, options: nil)
        //myCentral.scanForPeripherals(withServices: [vehicleServiceCBUUID])
     }
    
    func stopScanning() {
        print("stopScanning")
        //self.myCentral.cancelPeripheralConnection(peripheral)
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
            
            if(isPeripheralExists(name: peripheralName) == false) {
                //let newPeripheral = Peripheral(id: peripherals.count, name: peripheralName, uuid: UUID(uuidString: uuidString)!, rssi: RSSI.intValue)
                let newPeripheral = Peripheral(id: peripherals.count, name: peripheralName, rssi: RSSI.intValue, cbPeripheral: peripheral)
                print(newPeripheral)
                peripherals.append(newPeripheral)
            }
            
        }
        else {
            peripheralName = "Unknown"
            //Ignore the device
        }
        
        //if let uuidsKey = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? String {
        //    uuidString = uuidsKey
        //}
        //else {
        //    uuidString = "Unknown"
        //}
        

    }
    
    /**
     * Once connection is established, the centralManager didConnect delegate method gets called
     */
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        print("connected with " + peripheral.name!)
        print("Discovering Services......")
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
            print("No Services found!")
            return
        }
        print("Service found:")
        print(services)
        print("Discover Characteristics.......")
        discoverCharacteristics(peripheral: peripheral)
    }
     
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
        print("Found \(characteristics.count) characteristics.")
        // Consider storing important characteristics internally for easy access and equivalency checks later.
        // From here, can read/write to characteristics or subscribe to notifications as desired.
        for characteristic in characteristics {

                //if characteristic.uuid.isEqual(CBUUIDs.BLE_Characteristic_uuid_Rx)  {

                  //rxCharacteristic = characteristic

                  peripheral.setNotifyValue(true, for: characteristic)
                  peripheral.readValue(for: characteristic)

                  print("RX Characteristic: \(characteristic.uuid)")
            if (characteristic.uuid.uuidString == "2A57") {
                let valueString = ("1" as NSString).data(using: String.Encoding.utf8.rawValue)
                print("Write 1 to \(characteristic.uuid)")
                peripheral.writeValue(valueString!, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                print("Done")
            }
                //}

                //if characteristic.uuid.isEqual(CBUUIDs.BLE_Characteristic_uuid_Tx){
                  
                  //txCharacteristic = characteristic
                  
                  //print("TX Characteristic: \(txCharacteristic.uuid)")
                //}
              }
    }
    
    func disconnectPeripheral(peripheral: CBPeripheral) {
        self.myCentral.cancelPeripheralConnection(peripheral)
    }
    
    // Callback method for disconnect
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if (error != nil) {
            print("Error when disconnecting")// Handle error
            return
        }
        // Successfully disconnected
        print("Successfully disconnected")
    }
    
    func isPeripheralExists(name: String) -> Bool {
        return peripherals.contains(where: { $0.name == name })
        
    }
}
