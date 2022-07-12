//
//  ContentView.swift
//  VehicleActivator
//
//  Created by user222240 on 7/7/22.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var bleManager = BLEManager()
 
    var body: some View {
        VStack (spacing: 10) {
 
            Text("Bluetooth Devices")
                .font(.largeTitle)
                .frame(maxWidth: .infinity, alignment: .center)
            List(bleManager.peripherals) { peripheral in
                HStack {
                    Text(peripheral.name)
                    Button("Connect") {
                        //connect
                        bleManager.connectWithPeripheral(peripheral: peripheral.cbPeripheral)
                    }
                    Spacer()
                    Button("Disconnect") {
                        //connect
                        bleManager.disconnectPeripheral(peripheral: peripheral.cbPeripheral)
                    }
                    Spacer()
                    Text(String(peripheral.rssi))
                }
            }.frame(height: 300)
 
            Spacer()
 
            Text("Bluetooth STATUS")
                .font(.headline)
 
            // Status goes here
            if bleManager.isSwitchedOn {
                Text("Bluetooth is switched on")
                    .foregroundColor(.green)
            }
            else {
                Text("Bluetooth is NOT switched on")
                    .foregroundColor(.red)
            }
 
            Spacer()
 
            HStack {
                VStack (spacing: 10) {
                    Button(action: {
                        self.bleManager.startScanning()
                    }) {
                        Text("Start Scanning")
                    }
                    Button(action: {
                        self.bleManager.stopScanning()
                    }) {
                        Text("Stop Scanning")
                    }
                }.padding()
            }
            Spacer()
        }
    }
}
 
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
