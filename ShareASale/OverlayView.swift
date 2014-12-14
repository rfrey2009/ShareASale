//
//  OverlayView.swift


import Foundation
import UIKit

enum GGOverlayViewMode: Int {
    case Left
    case Right
}

class OverlayView: UIView{
    var mode: GGOverlayViewMode?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.layer.borderWidth = 3
        self.layer.borderColor = UIColor.blueColor().CGColor
    }
}