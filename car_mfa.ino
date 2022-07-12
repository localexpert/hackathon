/*
  Enabling BLE on MKR WiFi 1010

  This sketch controls an LED on a MKR WiFi 1010 board
  and makes a random reading of an analog pin.
   
  The data recorded can be accessed through Bluetooth,
  using an app such as LightBlue.
  
  Based on the Arduino BLE library, Battery Monitor example.

  (c) 2020 K. Söderby for Arduino
*/


#include <ArduinoBLE.h>



BLEService newService("180A"); // creating the service

BLEUnsignedCharCharacteristic randomReading("2A58", BLERead | BLENotify); // creating the Analog Value characteristic
BLEByteCharacteristic switchChar("2A57", BLERead | BLEWrite); // creating the LED characteristic

const int ledPin = 2;
long previousMillis = 0;


void setup() {
  
  Serial.begin(9600);    // initialize serial communication
  // while (!Serial);       //starts the program if we open the serial monitor.
  
  pinMode(LED_BUILTIN, OUTPUT); // initialize the built-in LED pin to indicate when a central is connected
  pinMode(ledPin, OUTPUT); // initialize the built-in LED pin to indicate when a central is connected

  //initialize BLE library
  if (!BLE.begin()) {
    Serial.println("starting BLE failed!");
    while (1);
  }

  String address = BLE.address();

  Serial.print("Local address is: ");
  Serial.println(address);


  BLE.setLocalName("MKR WiFi 1010A"); //Setting a name that will appear when scanning for bluetooth devices
  BLE.setAdvertisedService(newService);

  newService.addCharacteristic(switchChar); //add characteristics to a service
  newService.addCharacteristic(randomReading);

  BLE.addService(newService);  // adding the service

  switchChar.writeValue(0); //set initial value for characteristics
  randomReading.writeValue(0);

  BLE.advertise(); //start advertising the service
  Serial.println("Bluetooth device active, waiting for connections...");
  
}

void loop() {
  
  BLEDevice central = BLE.central(); // wait for a BLE central

  if (central) {  // if a central is connected to the peripheral
    Serial.print("Connected to central: ");
    
    Serial.println(central.address()); // print the central's BT address
  
     
    digitalWrite(LED_BUILTIN, HIGH); // turn on the LED to indicate the connection

    // check the battery level every 200ms
    // while the central is connected:
    while (central.connected()) {
      long currentMillis = millis();
      
      if (currentMillis - previousMillis >= 200) { // if 200ms have passed, we check the battery level
        previousMillis = currentMillis;

        int randomValue = analogRead(A1);
        randomReading.writeValue((int) central.rssi()); // was randomValue

        if (switchChar.written()) {
          if (switchChar.value()) {   // any value other than 0
            Serial.println("LED on");
            digitalWrite(ledPin, HIGH);         // will turn the LED on
            digitalWrite(1,HIGH);
   
          } else {                              // a 0 value
            Serial.println(F("LED off"));
  
            digitalWrite(ledPin, LOW);          // will turn the LED off
            digitalWrite(1,LOW);
          }
        }

      }
    }
    
    digitalWrite(LED_BUILTIN, LOW); // when the central disconnects, turn off the LED
    digitalWrite(ledPin, LOW); // turn relay off when disconnected
    Serial.print("Disconnected from central: ");
    
    Serial.println(central.address());
   
  }
}


