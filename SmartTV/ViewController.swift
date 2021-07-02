//
//  ViewController.swift
//  SmartTV
//
//  Created by paxcreation on 7/1/21.
//

import UIKit
import SmartView
import Pods_SmartTV
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    @IBOutlet weak var btVolume: UIButton!
    var app: Application?
//             static var sharedInstance = PhotoShareController()
    let serviceSearch = Service.search()
    var services = [Service]()
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupServices()
        
        self.btVolume.rx.tap.bind { _ in
            let eventID: String = "fireMissile"
            let msgData: [String : Any] = ["speed" : "100" as Any]
//                let binData: Data = Data(base64Encoded: image)

            // Publish an event containing a text message payload
            self.app?.publish(event: eventID, message: msgData as AnyObject?)
        }.disposed(by: disposeBag)
        
    }

    private func setupServices() {
        serviceSearch.delegate = self
        serviceSearch.start()
    }
    
    func connect(_ service: Service) {
        
        // Example for installed app
//        let appId: String = "111299000796"
        // Example for web app
//        let appId: URL = URL(string: "http://yourwebapp.com")
        
//        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                //If convert to m4a is Error, try to use like .caf or .aifc or aiff.
//                var appId = URL(fileURLWithPath: documentsPath)
        
//        let channelID: String = "com.samsung.multiscreen.photoshare"
//        com.samsung.multiscreen.photoshare
        
        let appURL: String = "http://prod-multiscreen-examples.s3-website-us-west-1.amazonaws.com/examples/photoshare/tv/"
        let channelId: String = "com.samsung.multiscreen.photoshare"
        
        

        if (app == nil){
        app = service.createApplication(URL(string: appURL)! as AnyObject,channelURI: channelId, args: nil)
        }
        app?.delegate = self

        app!.connectionTimeout = 5
//        self.isConnecting = true
//        self.isConnected = false
//        self.updateCastStatus()
        app!.connect()
        
        service.getDeviceInfo(5) { (info, _) in
//            print("==== info \(info)")
//            let json = NSString(format: "{\"value\":%d}", 100)
//            self.app?.publish(event: "volume", message: json)


        }
        
        app!.connect(nil) { (user, err) in
            print("===== user \(user)")
            print("===== err \(err)")
        }
        
//        print("]] \(app!.me)")
        
        
//        NSString *json = [NSString stringWithFormat:@"{\"value\":%d}", (volume < 100)?++volume:volume];
//        [[DataManager getInstance].app publishWithEvent:@"volume" message:json];

        }

}
extension ViewController: ServiceSearchDelegate {
    func onServiceFound(_ service: Service) {
        services.append(service)
        self.connect(service)
    }
    func onServiceLost(_ service: Service) {
        
    }
    
    func onStart() {
        print("===== start")
    }
    
    func onStop() {
        
    }
    
}

extension ViewController: ChannelDelegate {
    func onConnect(_ client: ChannelClient?, error: NSError?) {
        if (error != nil) {
//            serviceSearch.start()
        }
    }
    func onDisconnect(_ error: NSError?) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "onDisconnect"), object: self, userInfo: nil)
        serviceSearch.start()
    }
    
    func onReady() {
        print("=====")
    }
}
