//
//  ViewController.swift
//  CalculatorPP
//
//  Created by HuangYaqing on 12/04/2017.
//  Copyright (c) 2017 HuangYaqing. All rights reserved.
//

import UIKit
import CalculatorPP

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let rt = CalculatorPP.Calculate(str: "1+2")
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

