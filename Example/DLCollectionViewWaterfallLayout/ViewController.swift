//
//  ViewController.swift
//  DLCollectionViewWaterfallLayout
//
//  Created by jackincitibank@gmail.com on 05/17/2020.
//  Copyright (c) 2020 jackincitibank@gmail.com. All rights reserved.
//

import UIKit
import DLCollectionViewWaterfallLayout
import MJRefresh

let kCELLIDENTIFIER = "WaterfallCell"
let kHEADERIDENTIFIER = "WaterfallHeader"
let kFOOTERIDENTIFIER = "WaterfallFooter"
let kCellCount = 30

class ViewController: UIViewController {
    
    var collectionView: UICollectionView?
    var cellSizes: Array<NSValue> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor=UIColor.white
        let layout = DLCollectionViewWaterfallLayout()
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10)
        layout.headerHeight = 15
        layout.footerHeight = 10
        layout.minimumColumnSpacing = 20
        layout.minimumInteritemSpacing = 30
        
        for _ in 0...kCellCount-1 {
            let size = CGSize(width: 50 + Int(arc4random()) % 50, height: 50 + Int(arc4random() % 50))
            cellSizes.append(NSValue(cgSize: size))
        }
        
        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView?.autoresizingMask = [.flexibleHeight ,.flexibleWidth]
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(DLCollectionViewWaterfallCell.self, forCellWithReuseIdentifier: kCELLIDENTIFIER)
        collectionView?.register(DLCollectionViewWaterfallHeader.self,
                                 forSupplementaryViewOfKind: kDLCollectionElementKindSectionHeader,
                                 withReuseIdentifier: kHEADERIDENTIFIER)
        collectionView?.register(DLCollectionViewWaterfallFooter.self,
                                 forSupplementaryViewOfKind: kDLCollectionElementKindSectionFooter,
                                 withReuseIdentifier: kFOOTERIDENTIFIER)
        self.view.addSubview(collectionView!)
        
        
        let header = MJRefreshNormalHeader()
        header.setRefreshingTarget(self, refreshingAction: #selector(ViewController.headerRefresh))
        collectionView?.mj_header = header
    }
    
    @objc func headerRefresh(){
        collectionView?.mj_header?.endRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return kCellCount
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: DLCollectionViewWaterfallCell = collectionView.dequeueReusableCell(withReuseIdentifier: kCELLIDENTIFIER, for: indexPath) as! DLCollectionViewWaterfallCell
        
        cell.setDisplayString(displayString: "\(indexPath.item)")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableView = UICollectionReusableView()
        if kind == kDLCollectionElementKindSectionHeader {
            reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kDLCollectionElementKindSectionHeader, withReuseIdentifier: kHEADERIDENTIFIER, for: indexPath)
        } else if kind == kDLCollectionElementKindSectionFooter {
            reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kDLCollectionElementKindSectionFooter, withReuseIdentifier: kFOOTERIDENTIFIER, for: indexPath)
        }
        
        return reusableView
    }
    
}

extension ViewController: DLCollectionViewWaterfallLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeforIndexPath: IndexPath) -> CGSize {
        return cellSizes[sizeforIndexPath.item].cgSizeValue
    }
}
