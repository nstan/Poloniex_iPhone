//
//  ViewController.swift
//  Poloniex2
//
//  Created by Nikola Stan on 7/18/17.
//  Copyright © 2017 Nikola Stan. All rights reserved.
//

import UIKit
import Foundation
import Swamp


var lastRequestTime : DispatchTime = DispatchTime.now()
let minTimeBetweenRequest:Int = 1
var s = ""
var k = ""
//let tickerRecievedNotificationKey = "nikolastan.com.tickerRecievedNotificationKey"


class HomeScreenController: UIViewController, SwampSessionDelegate {
 
    
    @IBOutlet weak var publicKeyLabel: UILabel!
    @IBOutlet weak var secretKeyLabel: UILabel!
    @IBOutlet weak var openOrdersLabel: UILabel!
    @IBOutlet weak var currencyPairLabel: UILabel!
    @IBOutlet weak var lastLabel: UILabel!
    
    var t : Ticker = Ticker(currencyPair: "", last: 0, lowestAsk: 0, highestBid: 0, percentChange: 0, baseVolume: 0, quoteVolume: 0)
    var currencyPairSetting = "USDT_ETH"
    
//    let tickerRecievedNotificationName = Notification.Name(rawValue: tickerRecievedNotificationKey)
//    
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadKeysFromKeychain ()
        updateView ()
        let swampTransport = WebSocketSwampTransport(wsEndpoint:  URL(string: "wss://api.poloniex.com")!)
        let swampSession = SwampSession(realm: "realm1", transport: swampTransport)
        
//        // Set delegate for callbacks
//        NotificationCenter.default.addObserver(self, selector: #selector(HomeScreenController.updateTicker), name: tickerRecievedNotificationName, object: nil)
        swampSession.delegate = self
        swampSession.connect()
        
        
    }
    

    func swampSessionHandleChallenge(_ authMethod: String, extra: [String : Any])-> String {
        print("authMethod is " + authMethod)
        for (key, value) in extra {
            print ("first element in the extra parameter is: " + key + (value as! String) )
        }
        return "data handled"
    }
    
    func swampSessionConnected(_ session: SwampSession, sessionId: Int) {
        print ("Swamp session connected, ID : \(sessionId)")
        session.subscribe("ticker", options: ["disclose_me": true],
                          onSuccess: { subscription in
                            print ("subscribe successful")
                            // subscription can be stored for subscription.cancel()
        }, onError: { details, error in print ("error subscribing:" + error)
            // handle error
        }, onEvent: { details, results, kwResults in
            let cp = results?[0] as! String
            if cp == self.currencyPairSetting {
                self.t = Ticker(currencyPair: (results?[0] as! String), last: Double(results?[1] as! String)!, lowestAsk: Double(results?[2] as! String)!, highestBid: Double(results?[3] as! String)!, percentChange: Double(results?[4] as! String)!, baseVolume: Double(results?[5] as! String)!, quoteVolume: Double(results?[6] as! String)!)
                self.updateView()
            }
                // Event data is usually in results, but manually check blabla yadayada
        })
    }
    
    func swampSessionEnded(_ reason: String){
        print ("Session ended for the reason: " + reason)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        // Dispose of any resources that can be recreated.
    }
    
    

    @IBAction func logoutButton(_ sender: UIButton) {

        performSegue(withIdentifier: "authenticate", sender: self)
        
    }
    
    @IBAction func checkOpenOrdersButton(_ sender: UIButton) {
        var response : String = ""
        let (oO, e) = OpenOrdersLoader.returnOpenOrders(currencyPair:"all", keys!)
        for x in oO {
            response = response + String.localizedStringWithFormat("%@: (%@) %.3f at the price of %.3f\n", x.currencyPair!, x.type!, x.amount!, x.rate!)
        }
        if !e.isEmpty {
            openOrdersLabel.text = e
        }
        else {
            openOrdersLabel.text = response
        }

    }
    
    
    
    
    func updateView () {
        currencyPairLabel.text = self.t.currencyPair
        lastLabel.text = String(self.t.last)
    }
    
    func loadKeysFromKeychain () {
        keys = KeyLoader.loadKeys(
            "publicKey", "secretKey")
        guard let x = keys?.key, let y = keys?.secret else {
            print("error reading keys from the keychain")
            return
        }
        k = x; s = y;
        if x==nil || y==nil {
            k = "";
            s = k;
        }
        publicKeyLabel.text = k
        secretKeyLabel.text = s
    }
    
}

