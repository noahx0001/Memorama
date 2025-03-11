//
//  JuegoViewController.swift
//  Memorama
//
//  Created by Noe  on 11/03/25.
//

import UIKit
import AVFoundation

class JuegoViewController: UIViewController {
    var cardImages = ["card1", "card2", "card3", "card4", "card5", "card6", "card7", "card8", "card9", "card10", "card11", "card12"]
       var flippedCards = [UIButton]()
       var matchedCards = [UIButton]()
       var timer: Timer?
       var timeElapsed = 0
       var errors = 0
       var audioPlayer: AVAudioPlayer?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func regresar() {
        dismiss(animated: true)
    }
}
