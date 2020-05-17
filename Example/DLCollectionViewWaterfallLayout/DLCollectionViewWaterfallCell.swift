//
//  DLCollectionViewWaterfallCell.swift
//  DLCollectionViewWaterfallLayout_Example
//
//  Created by magi on 2020/5/17.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class DLCollectionViewWaterfallCell: UICollectionViewCell {
    var displayLabel: UILabel?
    var displayString: String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.displayLabel = UILabel(frame: self.bounds)
        self.displayLabel?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.displayLabel?.backgroundColor = UIColor.lightGray
        self.displayLabel?.textColor = UIColor.white
        self.displayLabel?.textAlignment = .center
        self.addSubview(self.displayLabel!)
    }
    
    func setDisplayString(displayString: String) {
        if self.displayString != displayString {
            self.displayLabel?.text = displayString
            self.displayString = displayString
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
