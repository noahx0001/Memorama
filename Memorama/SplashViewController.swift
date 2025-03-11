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

        imvSplash.frame.size.width = 0
        imvSplash.frame.size.height = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        var w = 0.0
        var h = 0.0
        var x = view.frame.width/2.0
        var y = view.frame.height/2.0
        imvSplash.frame = CGRect(x: x, y: y, width: w, height: h)
        w = view.frame.width * 0.8
        h = w
        x = (view.frame.width - w)/2.0
        y = (view.frame.height - h)/2.0
        UIView.animate(withDuration: 2, delay: 0.5) {
            self.imvSplash.frame = CGRect(x: x, y: y, width: w, height: h)
        } completion: { res in
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { tiempo in
                self.performSegue(withIdentifier: "sgSplash", sender: nil)
            }
        }
    }
}
