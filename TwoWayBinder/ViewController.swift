//
//  ViewController.swift
//  TwoWayBinder
//
//  Created by Kyle Peeler on 11/2/24.
//
// Based on https://diamantidis.github.io/2020/02/02/two-way-communication-between-ios-wkwebview-and-web-page

import UIKit
import WebKit

class ViewController: UIViewController, WKScriptMessageHandler {
    
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView;
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            webView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor)
        ])
        
        let contentController = self.webView.configuration.userContentController
        contentController.add(self, name: "paymentPlansMessageHandler")
        
        let exampleJS = """
        console.log('Test - example of injection of JS from WKWebView
        """

        let script = WKUserScript(source: exampleJS, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        contentController.addUserScript(script)
        
        if let url = Bundle.main.url(forResource: "index", withExtension: "html") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let dict = message.body as? [String: Any] else { return }
        
        print("Received message:")
        print(dict)
        
        guard let message = dict["message"] else {
            return
        }
        
        let script = "document.getElementById('value').innerText = \"\(message)\""
        
        webView.evaluateJavaScript(script) { (result, error) in
            if let result = result {
                print("Label is updated with message \(result)")
            } else if let error = error {
               print("An error occured: \(error)")
            }
        }
    }
}
