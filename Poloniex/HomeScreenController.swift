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
import AVFoundation

var lastRequestTime : DispatchTime = DispatchTime.now()



class HomeScreenController: UIViewController, SwampSessionDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var currencyPairPickerView: UIPickerView!
    @IBOutlet weak var openOrdersLabel: UILabel!
    @IBOutlet weak var currencyPairLabel: UILabel!
    @IBOutlet weak var lastLabel: UILabel!
    
    let tickerNotificationName = Notification.Name(rawValue:tickerUpdatedNotificationKey)
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var tickr : Ticker = Ticker(currencyPair: "", last: 0, lowestAsk: 0, highestBid: 0, percentChange: 0, baseVolume: 0, quoteVolume: 0)
    var currencyPairSetting = "USDT_ETH"
    var currencyPairList = ["USDT_ETH", "BTC_ETH", "USDT_BTC"]
    
    var downUrl = URL(fileURLWithPath: Bundle.main.path(forResource: "down", ofType:"mp3")!)
    var upUrl = URL(fileURLWithPath: Bundle.main.path(forResource: "up", ofType:"mp3")!)
    var sameUrl = URL(fileURLWithPath: Bundle.main.path(forResource: "same", ofType:"mp3")!)
    var audioPlayerUp = AVAudioPlayer()
    var audioPlayerSame = AVAudioPlayer()
    var audioPlayerDown = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        /* Initialize audio players */
        do {
            audioPlayerUp = try AVAudioPlayer(contentsOf: upUrl)
            audioPlayerDown = try AVAudioPlayer(contentsOf: downUrl)
            audioPlayerSame = try AVAudioPlayer(contentsOf: sameUrl)
        }
        catch { print ("couldn't load audio file") }
        
        /* Initialize the view */
        lastLabel.text = "0"
        // Making sure the Picker view initial value matches the value stored in user defaults
        let defaults = UserDefaults.standard
        let x = defaults.object(forKey: "Currency Pair") as! String?
        if (x == nil) {defaults.set(currencyPairSetting, forKey: "Currency Pair")} else {currencyPairSetting = x!}
        currencyPairPickerView.delegate = self
        currencyPairPickerView.dataSource = self
        currencyPairPickerView.selectRow(currencyPairList.index(of: currencyPairSetting)!, inComponent: 0, animated: true)
        
        
        updateView ()
        keys = KeyLoader.loadKeys("publicKey", "secretKey")
        let swampTransport = WebSocketSwampTransport(wsEndpoint:  URL(string: "wss://api.poloniex.com")!)
        let swampSession = SwampSession(realm: "realm1", transport: swampTransport)
        
        //        // Set delegate for callbacks
        //        NotificationCenter.default.addObserver(self, selector: #selector(HomeScreenController.updateTicker), name: tickerRecievedNotificationName, object: nil)
        swampSession.delegate = self
        swampSession.connect()
        createObservers()
        
    }
    
    
    
    func createObservers() {
        // ticker update observer
        NotificationCenter.default.addObserver(self, selector: #selector(HomeScreenController.updateTickerLabel(notification:)), name: tickerNotificationName, object: nil)
    }
    
    func updateTickerLabel (notification: NSNotification) {
        let difference : Double = self.tickr.last - Double(self.lastLabel.text ?? "0")!
        if difference.isLess(than: -tickerUpdatePriceChangeThreshold) {
            
                self.audioPlayerDown.play()
                print("price down")
        } else if !(difference.isLessThanOrEqualTo(tickerUpdatePriceChangeThreshold)) {
                self.audioPlayerUp.play()
                print("price up")
        } else {
            self.audioPlayerSame.play()
            print("price within +- 0.1")
        }
        self.lastLabel.text = String(self.tickr.last)
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
                self.tickr = Ticker(currencyPair: (results?[0] as! String), last: Double(results?[1] as! String)!, lowestAsk: Double(results?[2] as! String)!, highestBid: Double(results?[3] as! String)!, percentChange: Double(results?[4] as! String)!, baseVolume: Double(results?[5] as! String)!, quoteVolume: Double(results?[6] as! String)!)
                let name = Notification.Name(rawValue:tickerUpdatedNotificationKey)
                NotificationCenter.default.post(name: name, object: nil)
                
//                self.updateView()
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
    
    /* Picker view functions */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencyPairList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencyPairList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currencyPairSetting = currencyPairList[row]
        let defaults = UserDefaults.standard
        defaults.set(currencyPairSetting, forKey: "Currency Pair")
    }
    
    
    
    @IBAction func checkOpenOrdersButton(_ sender: UIButton) {
        DispatchQueue.global(qos: .userInitiated).async {
            var response : String = ""
            
            let (oO, e) = OpenOrdersLoader.returnOpenOrders(currencyPair:"all", keys!)
            DispatchQueue.main.async {
                for x in oO {
                    response = response + String.localizedStringWithFormat("%@: (%@) %.3f at the price of %.3f\n", x.currencyPair!, x.type!, x.amount!, x.rate!)
                }
                if !e.isEmpty {
                    self.openOrdersLabel.text = e
                }
                else {
                    self.openOrdersLabel.text = response
                }
            }
        }
        
    }
    
    
    func updateView () {
//            lastLabel.text = String(self.tickr.last)
    }
}


