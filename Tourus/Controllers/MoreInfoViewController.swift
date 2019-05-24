//
//  MoreInfoViewController.swift
//  Tourus
//
//  Created by admin on 24/05/2019.
//  Copyright © 2019 Tourus. All rights reserved.
//

import UIKit

class MoreInfoViewController: UIViewController {

    var name:String = ""
   
    @IBOutlet var interactionName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

       interactionName.text = name
    }
    
    @IBAction func onCloseClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    func displayInteractionInfo(_ interaction:Interaction?)
    {
        name = interaction?.place?.name ?? ""
    }
    
    func displayInteractionInfo(name:String?)
    {
        self.name = name ?? ""
    }
}
