//
//  DLCollectionViewWaterfallLayoutDelegate.swift
//  DLCollectionViewWaterfallLayout
//
//  Created by magi on 2020/5/17.
//

import UIKit

public protocol DLCollectionViewWaterfallLayoutDelegate: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeforIndexPath: IndexPath) -> CGSize
}
