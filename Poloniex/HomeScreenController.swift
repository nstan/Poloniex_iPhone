//
//  ViewController.swift
//  Poloniex2
//
//  Created by Nikola Stan on 7/18/17.
//  Copyright © 2017 Nikola Stan. All rights reserved.
//

import UIKit
import Foundation


var lastRequestTime : DispatchTime = DispatchTime.now()
let minTimeBetweenRequest:Int = 1
var s = ""
var k = ""



class HomeScreenController: UIViewController {
 
    
    @IBOutlet weak var publicKeyLabel: UILabel!
    @IBOutlet weak var secretKeyLabel: UILabel!
    @IBOutlet weak var openOrdersLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateView ()

        
 

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

