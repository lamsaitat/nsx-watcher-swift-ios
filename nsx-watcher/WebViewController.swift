//
//  ViewController.swift
//  nsx-watcher
//
//  Created by Kelvin Lam on 17/7/17.
//  Copyright © 2017 Henshin Soft Pty Ltd. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
    
    var entry: NSXEntry!
    
    @IBOutlet var webView: UIWebView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let urlString = entry.detailPageUrl, let url = URL(string: urlString) {
            webView.loadRequest(URLRequest(url: url))
        } else {
            self.title = "Url not correct..."
        }
    }
}

