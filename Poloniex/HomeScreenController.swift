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
    let orderBookNotificationName = Notification.Name(rawValue:orderBookAndTradesUpdatedNotificationKey)
    
    var averageTicker : [Double] = Array<Double>(repeating: Double(), count: liveFeedSize)
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var currencyPairSetting = "USDT_ETH"
    var currencyPairList = ["USDT_ETH", "BTC_ETH", "USDT_BTC"]
    
    var tickr : LiveTicker = LiveTicker(currencyPair: "", last: 0, lowestAsk: 0, highestBid: 0, percentChange: 0, baseVolume: 0, quoteVolume: 0, isFrozen: false, twentyFourHrHigh: 0, twentyFourHrLow: 0)
    var ordrBk : LiveOrderBook = LiveOrderBook(currencyPair: "", rate: 0, type: "", amount: 0)
    
    
    //    var downUrl = URL(fileURLWithPath: Bundle.main.path(forResource: "singleBeat", ofType:"mp3")!)
    var doubleBeatURL = URL(fileURLWithPath: Bundle.main.path(forResource: "doubleBeat", ofType:"mp3")!)
    var singleBeatURL = URL(fileURLWithPath: Bundle.main.path(forResource: "singleBeat", ofType:"mp3")!)
    
    var audioEngine: AVAudioEngine!
    var audioFile: AVAudioFile!
    
    //    var audioPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioEngine = AVAudioEngine()
        do {
            try audioFile = AVAudioFile(forReading: doubleBeatURL)
        } catch {print (error)}
        
        //        self.audioPlayer.stop()
        self.audioEngine.stop()
        self.audioEngine.reset()
        
        let audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)
        let changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = 1000
        audioEngine.attach(changePitchEffect)
        audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
        audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)
        try! audioEngine.start()
        audioPlayerNode.play()
        
        
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
        
        // Swamp connection to Poloniex Push Api
        let swampTransport = WebSocketSwampTransport(wsEndpoint:  URL(string: "wss://api.poloniex.com")!)
        let swampSession = SwampSession(realm: "realm1", transport: swampTransport)
        swampSession.delegate = self
        swampSession.connect()
        
        // Initiating created observers
        createObservers()
    }
    
    
    func playAudioWithVariablePitch (pitch: Double) {
        //        self.audioPlayer.stop()
        self.audioEngine.stop()
        self.audioEngine.reset()
        
        let audioPlayerNode = AVAudioPlayerNode()
        self.audioEngine.attach(audioPlayerNode)
        
        let changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = Float(pitch)
        self.audioEngine.attach(changePitchEffect)
        
        self.audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
        self.audioEngine.connect(changePitchEffect, to: self.audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(self.audioFile, at: nil, completionHandler: nil)
        try! self.audioEngine.start()
        audioPlayerNode.play()
    }
    
    func createObservers() {
        // ticker update observer
        NotificationCenter.default.addObserver(self, selector: #selector(HomeScreenController.updateTickerLabel(notification:)), name: tickerNotificationName, object: nil)
    }
    
    func updateTickerLabel (notification: NSNotification) {
        print ("Last price: \(Double(self.lastLabel.text!)!) New Price: \(self.tickr.last)")
        let i = averageTicker.add(number: self.tickr.last)
        let movingPointAverage = averageTicker.movingPointAverage(numberOfRecentElementsToAverage: movingAverageSize, dataSize: i)
        let relativeDifference : Double = 100*(self.tickr.last/movingPointAverage - 1)
        print ("MPA: \(movingPointAverage)")
        print ("rel diff: \(relativeDifference)")
        print ("rel diff: \(self.tickr.percentChange)")
        var pitch = pitchMean + relativeDifference*pitchDeviation
        if pitch.isLess(than: 0) {pitch = 1}
        playAudioWithVariablePitch (pitch: pitch)
        print ("pitch: \(pitch)")
        self.lastLabel.text = String(self.tickr.last) //update the screen ticker
    }
    
    func processOrderData (_ kwResults: [String:Any]?, _ results: [Any?]) {
        let seq = kwResults!["seq"] as! Int
        print ("seq number is \((seq))")
        
        for x in results {
            guard let x = x as! [AnyHashable: Any]?, let y:[AnyHashable:Any] = x["data"] as! [AnyHashable : Any], let type = x["type"] as! String? else {print ("problem reading data"); return}
            switch type {
            case "orderBookModify":
                print("case is orderBookModify")
            case "orderBookRemove":
                print("case is orderBookRemove")
            case "newTrade":
                print("case is newTrade")
            default:
                true;
            }
            print ("let's zee:" + (x["type"] as! String))
            print ("let's nee:" + (y["rate"] as! String))
            print ("let's nee:" + (y["type"] as! String))
        }
        
        
//        var json: [Any]?
        
//            do {
//                json = try JSONSerialization.jsonObject(with: results, options: JSONSerialization.ReadingOptions.mutableContainers)  as? [AnyObject]
//            } catch {
//                
//                print("error")
//                //handle errors here
//                
//            }

        //
//        guard let seq = kwResults["seq"] as! Int else {return}
//        do {
//            if let data = results ,
//                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]{
//                
//                }
//            }
//        catch {
//            print("Error deserializing JSON: \(error)")
//        }
//        
//        
//        do {
//            let dict:[String: Any?] = try JSONSerialization.jsonObject(with: results, options: nil) as! [String: Any?]
//            successful = (dict["success"] != nil)
//            message = dict["message"] as! String
//            amount = Double(dict["amount"] as! String)!
//        } catch {
//            print("couldn't decode JSON")
//            return }
//        NotificationCenter.default.post(name: self.orderBookNotificationName, object: nil)
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
        
        // Subscribe to ticker
        session.subscribe("ticker", options: ["disclose_me": true],
                          onSuccess: { subscription in
                            print ("subscribe successful")
                            // subscription can be stored for subscription.cancel()
        }, onError: { details, error in print ("error subscribing:" + error)
            // handle error
        }, onEvent: { details, results, kwResults in
            let cp = results?[0] as! String
            if cp == self.currencyPairSetting {
                self.tickr = LiveTicker(currencyPair: (results?[0] as! String), last: Double(results?[1] as! String)!, lowestAsk: Double(results?[2] as! String)!, highestBid: Double(results?[3] as! String)!, percentChange: Double(results?[4] as! String)!, baseVolume: Double(results?[5] as! String)!, quoteVolume: Double(results?[6] as! String)!, isFrozen: false, twentyFourHrHigh: 0, twentyFourHrLow: 0)
                NotificationCenter.default.post(name: self.tickerNotificationName, object: nil)
            }
            // Event data is usually in results, but manually check blabla yadayada
        })
        
        // Subscribe to currency pair order book and trades
        session.subscribe(currencyPairSetting, options: ["disclose_me": true],
                          onSuccess: { subscription in
                            print ("subscribe to \(self.currencyPairSetting) successful")
                            // subscription can be stored for subscription.cancel()
        }, onError: { details, error in print ("error subscribing:" + error)
            // handle error
        }, onEvent: { details, results, kwResults in
            print ("orderBook update received")
            
            self.processOrderData (kwResults, results!)
            
        })
        
//                self.tickr = Ticker(currencyPair: (results?[0] as! String), last: Double(results?[1] as! String)!, lowestAsk: Double(results?[2] as! String)!, highestBid: Double(results?[3] as! String)!, percentChange: Double(results?[4] as! String)!, baseVolume: Double(results?[5] as! String)!, quoteVolume: Double(results?[6] as! String)!)
        

            // Event data is usually in results, but manually check blabla yadayada
    
        
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
            var response : String = ""
            
            let (oO, e) = OpenOrdersLoader.returnOpenOrders(currencyPair:"all", keys!)
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
    
    
    func updateView () {
        //            lastLabel.text = String(self.tickr.last)
    }
}


