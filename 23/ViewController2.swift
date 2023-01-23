//
//  ViewController2.swift
//  23
//
//  Created by Paul Chartier on 22/01/2023.
//

import Foundation
import Combine
import UIKit

class ViewController2: UIViewController{
    
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var Button: UIButton!
    @IBOutlet var SysName: UILabel!

    @IBOutlet var arkit: UIImageView!
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIView.animateKeyframes(withDuration: 2.0, delay: 0.0, options: [.repeat, .autoreverse], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.25, animations: {
                self.arkit.transform = CGAffineTransform(translationX: -10, y: -5)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.25, animations: {
                self.arkit.transform = CGAffineTransform(translationX: 10, y: 5)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.25, animations: {
                self.arkit.transform = CGAffineTransform(translationX: -10, y: 5)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.25, animations: {
                self.arkit.transform = .identity
            })
        }, completion: nil)

    }
    
 
}
