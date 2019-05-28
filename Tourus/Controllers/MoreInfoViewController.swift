//
//  MoreInfoViewController.swift
//  Tourus
//
//  Created by admin on 24/05/2019.
//  Copyright © 2019 Tourus. All rights reserved.
//

import UIKit
import Cosmos

class MoreInfoViewController: UIViewController {

    var name: String = ""
    var rating: Double = 0.0
   
    @IBOutlet var backView: UIView!
    @IBOutlet var interactionName: UILabel!
    @IBOutlet var cosmosRatingView: CosmosView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setData()
        setTapDetection()
    }
    
    @objc func tapDetected() {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCloseClick(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    func displayInteractionInfo(name: String?, rating: Double?) {
        
        self.name = name ?? ""
        self.rating = rating ?? 0.0
    }
    
    private func setData() {
        
        interactionName.text = name
        cosmosRatingView.rating = rating
    }
    
    private func setTapDetection() {
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(MoreInfoViewController.tapDetected))
        self.backView.addGestureRecognizer(singleTap)
    }
}
