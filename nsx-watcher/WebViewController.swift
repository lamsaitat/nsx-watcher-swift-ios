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
        title = "Loading..."
        // Do any additional setup after loading the view, typically from a nib.
        if let urlString = entry.detailPageUrl, let url = URL(string: urlString) {
            webView.loadRequest(URLRequest(url: url))
        } else {
            title = "Url not correct..."
        }
    }
}

extension WebViewController: UIWebViewDelegate {
    func webViewDidStartLoad(_ webView: UIWebView) {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        spinner.tintColor = UIColor.blue
        spinner.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        navigationItem.rightBarButtonItem = nil
        title = entry.carId
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        navigationItem.rightBarButtonItem = nil
        title = "Failed to load"
    }
}
