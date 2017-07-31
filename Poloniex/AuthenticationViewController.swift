//
//  ViewController.swift
//  Poloniex2
//
//  Created by Nikola Stan on 7/18/17.
//  Copyright © 2017 Nikola Stan. All rights reserved.
//

import UIKit
import Foundation


class AuthenticationViewController: UIViewController {
    var k: String = ""
    var s: String = ""
    
    @IBOutlet weak var publicKeyTxt: UITextField!
    @IBOutlet weak var secretKeyTxt: UITextField!
    @IBOutlet weak var saveKeysSwitch: UISwitch!
//    func showAlert(message: String) {
//        print("showAlert function triggered")
//    }
    

    
//        let holdingsWithOrders = OrdersLoader.loadOrders(holdings, keys: keys)
//        alertHoldingsWithoutOrders(holdingsWithOrders)
//        let btcPrice = QuotesLoader.loadBTCPrice()
//        let portfolio = Portfolio(holdings: holdingsWithOrders, btcPrice: btcPrice)
//    

//    @IBAction func checkOpenOrders(_ sender: UIButton) {
//        var responseText: String
//        let openOrders = OpenOrdersLoader.returnOpenOrders(currencyPair:
//            "all", keys)
//        
//        if !openOrders.isEmpty {
//            responseText = openOrders[0].currencyPair! + " : \(String(describing: openOrders[0].amount!)) at \(String(describing: openOrders[0].rate!))"
//        }
//        else {
//        responseText = "No Orders"}
//        OpenOrdersTextField.text = responseText
//    }
    
//    @IBOutlet weak var OpenOrdersTextField: UITextField!
    
    @IBAction func saveKeysSwitchChanged(_ sender: UISwitch) {
        let defaults = UserDefaults.standard
        defaults.set(sender.isOn, forKey: "Save Keys")
    }

        
    override func viewDidLoad() {
        super.viewDidLoad()
        updateView ()
        populateKeyFields ()
        

       
        
        
//        do {
//            try Locksmith.saveData(data:
//                ["Public Key": "AFYCWCUY-YW9D6N1T-C2JYLJGH-QK9FPA2Q"], forUserAccount: "nstan")
//        }
//        catch {
//            print ("couldn't save data into keychain")
//        }
//        
//        do {
//            try Locksmith.saveData(data:
//                ["Secret Key": "1449a6a48c70d7cca568181f0fe0e8cf84ed2e3d5d1e0212fdc4e2aa3276a80bda5346e471fed2f9b04fce4b987f47c1d7c7f64c08aa930e496ca56da6f82a6f"], forUserAccount: "nstan", inService: "Poloniex")
//        }
//        catch {
//            print ("couldn't save data into keychain")
//        }
//        
//        let dictionary = Locksmith.loadDataForUserAccount(userAccount:
//        "nstan")
        
        
        
        
        
//        let holdings = HoldingsLoader.loadHoldings(keys)
//        let holdingsWithOrders = OrdersLoader.loadOrders(holdings, keys: keys)
//        print(holdingsWithOrders)
//////        alertHoldingsWithoutOrders(holdingsWithOrders)
//        
        /* tickers */
//        let tickers = TickerLoader.returnTicker()
//        print(tickers)
//        
//        /* 24h Volume */
//        let funcResponse = Volume24Loader.return24Volume()
//        let volumes = funcResponse.volumes
//        let totals = funcResponse.totals
//        
//        print(volumes)
//        print(totals)
//
        /* 24h Volume */
//        let funcResponse2 = OrderBookLoader.returnOrderBook(currencyPair: "all", depth: 10)
//        
//        let response25 = OpenOrdersLoader.returnOpenOrders(currencyPair:
//            "all", keys)

//      
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
//        formatter.timeZone = TimeZone.autoupdatingCurrent
//        let startDate = formatter.date(from: "2017/07/25 12:52:43") /*startDate is in UTC time zone, given string is in the current time zone*/
//        let endDate = formatter.date(from: "2017/07/25 12:52:45")
//        let funcResponse3 = TradeHistoryLoader.returnTradeHistory(currencyPair: "USDT_ETH", start: startDate!, end: endDate!)
////        let funcResponse4 = ChartDataLoader.returnChartData(currencyPair: "BTC_XMR", start: startDate!, end: endDate!, period: 14400)
////
//        let funcResponse5 = CurrenciesLoader.returnCurrencies()
//        /* example of search through an array of structs */
//        var responseFiltered = funcResponse5.filter{$0.currencyAbbrev == "GDN"}
//        for x in responseFiltered {
//            print (x.currencyName)
//        }
//        
//        let response6 = BalancesLoader.returnBalances(keys)
//        /* example of search through an array of structs */
//        var responseFiltered2 = response6.filter{$0.currencyAbbrev == "ETH"}
//        for x in responseFiltered2 {
//            print ("\(x.currencyAbbrev) : \(x.currencyAmount)")
//        }
        
//        let response7 = OpenOrdersLoader.returnOpenOrders(currencyPair: "USDT_ETH", keys)
//            
//            print(response7)
//        
        
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy/MM/dd HH:mm"
//        formatter.timeZone = TimeZone.autoupdatingCurrent
//        let startDate = formatter.date(from: "2017/07/26 07:00") /*startDate is in UTC time zone, given string is in the current time zone*/
//        let endDate = formatter.date(from: "2017/07/26 10:00")
//        let response8 = MyTradeHistoryLoader.returnTradeHistory(currencyPair: "USDT_ETH", start: startDate!, end: endDate!, keys)

//        let orderNo:Int = response25[0].orderNumber!

//        let response9 = MyOrderTradesLoader.returnOrderTrades(orderNumber: orderNo, keys)
        
//        let (successful, message, amount) = MyOrderCancelLoader.cancelOrder(orderNumber: orderNo, keys)
//        if successful {
//         print (message + " the amount of the order is : \(String(amount))")
//        } else {print ("Failed to cancel order.")}
}


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateView () {
        let defaults = UserDefaults.standard
        guard let x=defaults.object(forKey: "Save Keys") as! Bool? else {
            print ("error in user default value for Save Keys")
            return
        }
        saveKeysSwitch.setOn(x, animated: true)

    }
    
    func populateKeyFields () {
        let keychain = KeychainSwift()
        keys = KeyLoader.loadKeys(
            "publicKey", "secretKey")
        if keys != nil {
            if !saveKeysSwitch.isOn {
                keychain.delete("privateKey")
                keychain.delete("secretKey")
                k = ""; s = k
            } else {
                guard let x = keys?.key, let y = keys?.secret else {
                    print ("error fetching keys from keychain")
                    return
                }
                k = x; s = y;
            }
        } else {k = ""; s = k}
        publicKeyTxt.text = k
        secretKeyTxt.text = s
    }
    
    @IBAction func continueBttn(_ sender: UIButton) {
        let keychain = KeychainSwift()
        if publicKeyTxt.text != "" && secretKeyTxt.text != "" {
            keychain.set(publicKeyTxt.text!, forKey: "publicKey")
            keychain.set(secretKeyTxt.text!, forKey: "secretKey")
        }
        else {
            createAlert(titleText: "Warning", messageText: "Empty Fields")
        }
        guard let keys = KeyLoader.loadKeys("publicKey", "secretKey") else {
            print ("View Controller : no keys")
            return
        }
        print ("ContinueButton Keys: " + keys.key)
        
        self.performSegue(withIdentifier: "keysEntered", sender: self)
    }


    override func viewDidAppear(_ animated: Bool){
        
    }

    func createAlert(titleText: String, messageText: String){
        let alert = UIAlertController(title: titleText, message: messageText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {(action) in alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
//    func createAlert (title: String, message: String) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
//        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{(action) in alert.dismiss(animated: true, completion: nil)
//        }))
//        self.presentViewController(alert, animated: true, completion: nil)
//    }
    
}



