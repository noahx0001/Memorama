//
//  SplashViewController.swift
//  Memorama
//
//  Created by Noe  on 11/03/25.
//

import UIKit

class SplashViewController: UIViewController {

    @IBOutlet weak var imvSplash: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let w = view.frame.width * 0.8
        let h = w * 0.4318
        let x = (view.frame.width - w) / 2.0
        let y = -h
        
        imvSplash.frame = CGRect(x: x, y: y, width: w, height: h)
        imvSplash.alpha = 0.0
        
        UIView.animate(withDuration: 2.0) {
            self.imvSplash.frame.origin.y = (self.view.frame.height - h) / 2.0
            self.imvSplash.alpha = 1.0
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.performSegue(withIdentifier: "sgSplash", sender: nil)
            }
        }
    }
}
