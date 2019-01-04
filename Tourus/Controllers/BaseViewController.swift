//
//  BaseViewController.swift
//  Tourus
//
//  Created by admin on 03/01/2019.
//  Copyright © 2019 Tourus. All rights reserved.
//

import UIKit

class BaseViewController : UIViewController {
    
    override func viewDidLoad() {
    super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(displayP3Red: 10, green: 255, blue: 2, alpha: 2)
   //  let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
    // backgroundImage.image = UIImage(named: "bg_name.png")
   // backgroundImage.contentMode = UIViewContentMode.scaleAspectFill
   //  self.view.insertSubview(backgroundImage, at: 0)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
