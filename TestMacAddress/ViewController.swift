
import CoreLocation

import SystemConfiguration.CaptiveNetwork
import UIKit

class ViewController: UIViewController {
    
    var locationManager: CLLocationManager?


    @IBOutlet weak var SSIDLabel: UILabel!
    @IBOutlet weak var BSSIDLabel: UILabel!
    @IBOutlet weak var IPAddressLabel: UILabel!
    
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
}

extension ViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status == .authorizedAlways || status == .authorizedAlways {
 
    }
  }
}
