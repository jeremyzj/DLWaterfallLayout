//
//  DLCollectionViewWaterfallFooter.swift
//  DLCollectionViewWaterfallLayout_Example
//
//  Created by magi on 2020/5/17.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class DLCollectionViewWaterfallFooter: UICollectionReusableView {
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.backgroundColor = UIColor.blue
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
}
