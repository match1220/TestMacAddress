
import CoreLocation

import SystemConfiguration.CaptiveNetwork
import UIKit
import NetworkExtension


class ViewController: UIViewController {
    
    var locationManager: CLLocationManager?


    @IBOutlet weak var SSIDLabel: UILabel!
    @IBOutlet weak var BSSIDLabel: UILabel!
    @IBOutlet weak var IPAddressLabel: UILabel!
    @IBOutlet weak var MacAddressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
    }

   
    @IBAction func GetDataBtn(_ sender: UIButton) {
        
        
        SSIDLabel.text = getUsedSSID()
        BSSIDLabel.text = getUsedBSSID()
        IPAddressLabel.text = getIPAddress()
        MacAddressLabel.text = MACAddressForBSD(bsd: "en0")
        
        fetchNetworkInfo()
    }
    
    func fetchNetworkInfo() {
            NEHotspotNetwork.fetchCurrent { network in
                guard let network = network else { return }
                
                print("The SSID for the Wi-Fi network.")
                print("ssid:", network.ssid, "\n")
              

                print("The BSSID for the Wi-Fi network.")
                print("bssid:", network.bssid, "\n")
              
                
                print("The recent signal strength for the Wi-Fi network.")
                print("signalStrength:", network.signalStrength, "\n")
                
                print("Indicates whether the network is secure")
                print("isSecure:", network.isSecure, "\n")
                
                print("Indicates whether the network was joined automatically or was joined explicitly by the user.")
                print("didAutoJoin:", network.didAutoJoin, "\n")
                
                print("Indicates whether the network was just joined.")
                print("didJustJoin:", network.didJustJoin, "\n")
                
                print("Indicates whether the calling Hotspot Helper is the chosen helper for this network.")
                print("isChosenHelper:", network.isChosenHelper, "\n")
            }
        }
    
    func getUsedSSID() -> String {
        
        let interfaces = CNCopySupportedInterfaces()
        
        var ssid = ""
        
        if interfaces != nil {
            let interfacesArray = CFBridgingRetain(interfaces) as! Array<Any>
            
            if interfacesArray.count > 0{
                let interfaceName = interfacesArray[0] as! CFString
                
                let ussafeInterfaceData = CNCopyCurrentNetworkInfo(interfaceName)
                
                if (ussafeInterfaceData != nil){
                    
                    let interfaceData  = ussafeInterfaceData as! Dictionary<String, Any>

                    ssid = interfaceData["SSID"] as! String
                }
            }
        }
        return ssid
    }
    
    func getUsedBSSID() -> String {
        
        let interfaces = CNCopySupportedInterfaces()
        
        var bssid = ""
        
        if interfaces != nil {
            let interfacesArray = CFBridgingRetain(interfaces) as! Array<Any>
            
            if interfacesArray.count > 0{
                let interfaceName = interfacesArray[0] as! CFString
                
                let ussafeInterfaceData = CNCopyCurrentNetworkInfo(interfaceName)
                
                if (ussafeInterfaceData != nil){
                    
                    let interfaceData  = ussafeInterfaceData as! Dictionary<String, Any>

                    bssid = interfaceData["BSSID"] as! String
                }
            }
        }
        return bssid
    }
    
    func getIPAddress() -> String {
       
       var address: String?
       var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
       if getifaddrs(&ifaddr) == 0 {
           var ptr = ifaddr
           while ptr != nil {
               defer { ptr = ptr?.pointee.ifa_next }
               
               guard let interface = ptr?.pointee else { return "" }
               let addrFamily = interface.ifa_addr.pointee.sa_family
               if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                   
                   // wifi = ["en0"]
                   // wired = ["en2", "en3", "en4"]
                   // cellular = ["pdp_ip0","pdp_ip1","pdp_ip2","pdp_ip3"]
                   
                   let name: String = String(cString: (interface.ifa_name))
                   if  name == "en0" || name == "en2" || name == "en3" || name == "en4" || name == "pdp_ip0" || name == "pdp_ip1" || name == "pdp_ip2" || name == "pdp_ip3" {
                       var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                       getnameinfo(interface.ifa_addr, socklen_t((interface.ifa_addr.pointee.sa_len)), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                       address = String(cString: hostname)
                   }
               }
           }
           freeifaddrs(ifaddr)
       }
       return address ?? ""
   }
    
    
    func MACAddressForBSD(bsd : String) -> String?
    {
        let MAC_ADDRESS_LENGTH = 6
        let separator = ":"

        var length : size_t = 0
        var buffer : [CChar]

        let bsdIndex = Int32(if_nametoindex(bsd))
        if bsdIndex == 0 {
            print("Error: could not find index for bsd name \(bsd)")
            return nil
        }
        let bsdData = Data(bsd.utf8)
        var managementInfoBase = [CTL_NET, AF_ROUTE, 0, AF_LINK, NET_RT_IFLIST, bsdIndex]

        if sysctl(&managementInfoBase, 6, nil, &length, nil, 0) < 0 {
            print("Error: could not determine length of info data structure");
            return nil;
        }

        buffer = [CChar](unsafeUninitializedCapacity: length, initializingWith: {buffer, initializedCount in
            for x in 0..<length { buffer[x] = 0 }
            initializedCount = length
        })

        if sysctl(&managementInfoBase, 6, &buffer, &length, nil, 0) < 0 {
            print("Error: could not read info data structure");
            return nil;
        }

        let infoData = Data(bytes: buffer, count: length)
        let indexAfterMsghdr = MemoryLayout<if_msghdr>.stride + 1
        let rangeOfToken = infoData[indexAfterMsghdr...].range(of: bsdData)!
        let lower = rangeOfToken.upperBound
        let upper = lower + MAC_ADDRESS_LENGTH
        let macAddressData = infoData[lower..<upper]
        let addressBytes = macAddressData.map{ String(format:"%02x", $0) }
        return addressBytes.joined(separator: separator)
    }
    
}

extension ViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status == .authorizedAlways || status == .authorizedAlways {
 
    }
  }
}
