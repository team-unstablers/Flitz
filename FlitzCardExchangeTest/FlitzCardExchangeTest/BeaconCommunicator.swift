//
//  BLECommunicator.swift
//  FlitzCardExchangeTest
//
//  Created by Gyuhwan Park on 12/3/24.
//

import CoreBluetooth
import CoreLocation

extension UUID {
    static let serviceArea1 = UUID(uuidString: "09DC8B14-0970-469A-B83E-01FD64AA69DA")!
}

struct BeaconIdentity {
    let serviceUUID: UUID
    var major: CLBeaconMajorValue
    var minor: CLBeaconMinorValue
    
    func createBeaconRegion() -> CLBeaconRegion {
        return CLBeaconRegion(
            uuid: self.serviceUUID,
            major: self.major,
            minor: self.minor,
            identifier: "pl.unstabler.experimental.flitz.beacontest"
        )
    }
}

class BeaconCommunicator: NSObject, ObservableObject {
    static let shared = BeaconCommunicator()
    
    let locationManager = CLLocationManager()
    
    public var cbCentralManager = CBCentralManager()
    var cbManager: CBPeripheralManager!
    
    private var peripherals: Set<CBPeripheral> = []
    
    @Published
    var logs: [String] = []
    
    @Published
    var id: String = "HELOWRLD"

    @Published
    var identity: BeaconIdentity = BeaconIdentity(
        serviceUUID: .serviceArea1,
        major: 1,
        minor: 1
    )
    
    override init() {
        super.init()
        
        self.cbManager = CBPeripheralManager(delegate: self, queue: DispatchQueue.global(qos: .background))
        
        cbCentralManager.delegate = self
        locationManager.delegate = self
        cbManager.delegate = self

        self.sanityCheck()
    }
    
    func sanityCheck() {
    }
    
    func startListening() {
        let constraint = CLBeaconIdentityConstraint(uuid: .serviceArea1)
        
        let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: constraint,
                                          identifier: "pl.unstabler.experimental.flitz.beacontest")
        /*
        locationManager.activityType = .fitness
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = kCLDistanceFilterNone
        
        locationManager.startUpdatingLocation()
        locationManager.startRangingBeacons(satisfying: constraint)
         */
        
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.startRangingBeacons(satisfying: constraint)

        self.cbCentralManager.scanForPeripherals(withServices: [CBUUID(nsuuid: .serviceArea1)], options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }
    
    func startAdvertising() {
        let service = CBMutableService(type: CBUUID(nsuuid: .serviceArea1), primary: true)
        let characteristic = CBMutableCharacteristic(
            type: CBUUID(nsuuid: .serviceArea1),
            properties: [.read],
            value: self.id.data(using: .utf8),
            permissions: [.readable]
        )
        
        service.characteristics = [characteristic]
        
        self.cbManager.add(service)
        self.cbManager.startAdvertising([
            CBAdvertisementDataLocalNameKey: nil,
            CBAdvertisementDataServiceUUIDsKey: [CBUUID(nsuuid: .serviceArea1)],
        ])
        
    }
    
}

extension BeaconCommunicator: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            
        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()

            
            
        case .restricted, .denied:
            break
            
        case .authorizedAlways:
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.showsBackgroundLocationIndicator = true
            locationManager.pausesLocationUpdatesAutomatically = false
            self.logs.append("authorized")
            break
        }
        
        
        switch(manager.authorizationStatus) {
        case .authorizedAlways:
            print("authorized")
        case .notDetermined:
            print("not determined")
        case .authorizedWhenInUse:
            print("when in use")
        case .restricted:
            print("restricted")
        case .denied:
            print("denied")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        for beacon in beacons {
            logs.append("discovered: \(beacon.major) \(beacon.minor)")
        }
    }
}

extension BeaconCommunicator: CBPeripheralManagerDelegate {
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: (any Error)?) {
        print("didStartAdvertising")
    }
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print(peripheral.isAdvertising)
    }
    
}


extension BeaconCommunicator: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if (self.peripherals.contains(peripheral)) {
            return
        }
        
        self.peripherals.insert(peripheral)
        central.connect(peripheral)
        
        print("connecting")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connected")
        peripheral.delegate = self
        peripheral.discoverServices([CBUUID(nsuuid: .serviceArea1)])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        print("disconencted")
        self.peripherals.remove(peripheral)
    }
    
}

extension BeaconCommunicator: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        print("service discovered")
        
        guard let service = peripheral.services?.first else {
            self.cbCentralManager.cancelPeripheralConnection(peripheral)
            return
        }

        peripheral.discoverCharacteristics([CBUUID(nsuuid: .serviceArea1)], for: service)

        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        guard let characteristic = service.characteristics?.first else {
            self.cbCentralManager.cancelPeripheralConnection(peripheral)
            return
        }
        
        peripheral.readValue(for: characteristic)
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        logs.append("discovered \(String(data: characteristic.value!, encoding: .utf8))")
        self.cbCentralManager.cancelPeripheralConnection(peripheral)
    }
}


