//
//  ViewController.swift
//  TVSpiderChart
//
//  Created by Tri Vo on 4/20/19.
//  Copyright © 2019 Tri Vo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var viewChart : TVSpiderChart!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        viewChart.reload()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewChart.reload()
    }


}

