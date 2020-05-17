//
//  DLCollectionViewWaterfallLayout.swift
//  DLCollectionViewWaterfallLayout
//
//  Created by magi on 2020/5/17.
//

import UIKit

public let kDLCollectionElementKindSectionHeader = "kDLCollectionElementKindSectionHeader"

public let kDLCollectionElementKindSectionFooter = "kDLCollectionElementKindSectionFooter"

public class DLCollectionViewWaterfallLayout: UICollectionViewLayout {
    /**
    *  @brief How many columns for this layout.
    *  @discussion Default: 2
    */
    public var columnCount: Int = 2 {
        didSet {
            if oldValue != columnCount {
                self.invalidateLayout()
            }
        }
    }

    /**
     *  @brief The minimum spacing to use between successive columns.
     *  @discussion Default: 10.0
     */
    public var minimumColumnSpacing: Float = 10.0 {
        didSet {
            if oldValue != minimumColumnSpacing {
                self.invalidateLayout()
            }
        }
    }
    public var minimumInteritemSpacing: Float = 10.0 {
        didSet {
            if oldValue != minimumInteritemSpacing {
                self.invalidateLayout()
            }
        }
    }
    public var headerHeight: Float = 0.0 {
        didSet {
            if oldValue != headerHeight {
                self.invalidateLayout()
            }
        }
    }
    public var footerHeight: Float = 0.0 {
        didSet {
            if oldValue != footerHeight {
                self.invalidateLayout()
            }
        }
    }
    public var sectionInset: UIEdgeInsets = .zero {
        didSet {
            if oldValue != sectionInset {
                self.invalidateLayout()
            }
        }
    }
    
    public func itemWidthInSection(atIndex section: NSInteger) -> CGFloat {
        guard let collectionView = self.collectionView else {
            return 0.0
        }
        var sectionInsert: UIEdgeInsets = .zero
//        if let insert = self.delegate?.collectionView(collectionView, layout: self, insert: section) {
//            sectionInsert = insert
//        } else {
        sectionInsert = self.sectionInset
//        }
    
        let width: Float = Float(collectionView.frame.size.width - sectionInsert.left - sectionInsert.right)
        return CGFloat(floorf((Float(width) - Float(self.columnCount - 1) * self.minimumColumnSpacing) / Float(self.columnCount)))
    }
    
    weak var delegate : DLCollectionViewWaterfallLayoutDelegate? {
        return self.collectionView?.delegate as? DLCollectionViewWaterfallLayoutDelegate
    }
    
    
    var columnHeights: Array<Float> = []
    var sectionItemAttributes: Array<Array<UICollectionViewLayoutAttributes>> = []
    var allItemAttributes: Array<UICollectionViewLayoutAttributes> = []
    var headersAttribute: Dictionary<Int, UICollectionViewLayoutAttributes> = [:]
    var footersAttribute: Dictionary<Int, UICollectionViewLayoutAttributes> = [:]
    var unionRects: NSMutableArray = NSMutableArray()
    
}

extension DLCollectionViewWaterfallLayout {
    public override func prepare() {
        super.prepare()
        
        guard let collectionView = self.collectionView else {
            return
        }
        
        let numberOfSections = collectionView.numberOfSections
        if numberOfSections == 0 {
            return
        }
        
        columnHeights = []
        allItemAttributes = []
        sectionItemAttributes = []
        headersAttribute = [:]
        footersAttribute = [:]
        self.unionRects.removeAllObjects()
        
        for _ in 0...self.columnCount - 1 {
            self.columnHeights.append(0)
        }
        
        var top: Float = 0
        
        for section in 0...numberOfSections-1 {
            let minimumInteritemSpacing: Float = self.minimumInteritemSpacing
            let sectionInset: UIEdgeInsets = self.sectionInset
            let width = collectionView.frame.size.width - sectionInset.left - sectionInset.right
            let itemWidth = floorf((Float(width) - Float(self.columnCount-1) * self.minimumColumnSpacing) / Float(self.columnCount))
            
            let headerHeight = self.headerHeight
            
            if headerHeight > 0 {
                let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: kDLCollectionElementKindSectionHeader, with: IndexPath(item: 0, section: section))
                attributes.frame = CGRect(x: 0, y: Int(top), width: Int(collectionView.frame.size.width), height: Int(headerHeight))
                self.headersAttribute[section] = attributes
                self.allItemAttributes.append(attributes)
                
                top = Float(attributes.frame.maxY)
            }
            
            top += Float(sectionInset.top)
            for idx in 0...self.columnCount-1 {
                self.columnHeights[idx] = top
            }
            
            let itemCount = collectionView.numberOfItems(inSection: section)
            var itemAttributes: Array<UICollectionViewLayoutAttributes> = [UICollectionViewLayoutAttributes]()
            
            for idx in 0...itemCount-1 {
                let indexPath = IndexPath(item: idx, section: section)
                let columIndex = self.shortestColumnIndex()
                let xOffset = Float(sectionInset.left) + (itemWidth + self.minimumColumnSpacing) * Float(columIndex)
                let yOffset = self.columnHeights[columIndex]
                if let itemSize: CGSize = self.delegate?.collectionView(collectionView, layout: self, sizeforIndexPath: indexPath) {
                    var itemHeight: Float = 0
                    if itemSize.height > 0 && itemSize.width > 0 {
                        itemHeight = floorf(Float(itemSize.height * CGFloat(itemWidth) / itemSize.width))
                    }
                    
                    let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    attributes.frame = CGRect(x: Int(xOffset), y: Int(yOffset), width: Int(itemWidth), height: Int(itemHeight))
                    itemAttributes.append(attributes)
                    self.allItemAttributes.append(attributes)
                    self.columnHeights[columIndex] = Float(attributes.frame.maxY) + minimumInteritemSpacing
                }
            }
            self.sectionItemAttributes.append(itemAttributes)
            
            var footerHeight: Float = 0
            let columnIndex = self.longestColumnIndex()
            top = self.columnHeights[columnIndex] - minimumInteritemSpacing + Float(sectionInset.bottom)
            
            footerHeight = self.footerHeight
            if footerHeight > 0 {
                let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: kDLCollectionElementKindSectionFooter, with: IndexPath(item: 0, section: section))
                attributes.frame = CGRect(x: 0, y: Int(top), width: Int(collectionView.frame.size.width), height: Int(footerHeight))
             
                self.footersAttribute[section] = attributes
                self.allItemAttributes.append(attributes)
                top = Float(attributes.frame.maxY)
            }
            
            for idx in 0...self.columnCount-1 {
                self.columnHeights[idx] = top
            }
            
        }
        
        var idx = 0
        let itemCounts = self.allItemAttributes.count - 1
        while idx < itemCounts {
            let rect1 = self.allItemAttributes[idx].frame
            idx = min(idx + 20, itemCounts) - 1
            let rect2 = self.allItemAttributes[idx].frame
            let unionRect = rect1.union(rect2)
            self.unionRects.add(NSValue(cgRect: unionRect))
            idx += 1
        }
    }
    
    public override var collectionViewContentSize: CGSize {
        guard let collectionView = self.collectionView else {
            return CGSize(width: 0, height: 0)
        }
        let numberOfSections = collectionView.numberOfSections
        if numberOfSections == 0 {
            return CGSize(width: 0, height: 0)
        }
 
        var contentSize = collectionView.bounds.size
        contentSize.height = CGFloat(self.columnHeights[0])
        return contentSize
    }
    
//    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
//        if indexPath.section >= self.sectionItemAttributes.count {
//            return nil
//        }
//
//        if indexPath.item >= self.sectionItemAttributes[indexPath.section].count {
//            return nil
//        }
//
//        return self.sectionItemAttributes[indexPath.section][indexPath.item]
//    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var begin = 0, end = self.unionRects.count - 1
        for idx in 0...self.unionRects.count - 1 {
            if rect.intersects(self.unionRects[idx] as! CGRect) {
                begin = idx * 20
                break
            }
        }
        
        let unionRectCount = self.unionRects.count-1
        var index = unionRectCount
        while index >= 0 {
            if rect.intersects(self.unionRects[index] as! CGRect) {
                end = min((index + 1) * 20, self.allItemAttributes.count)
                break
            }
            index -= 1
        }
        
        var attrs : Array<UICollectionViewLayoutAttributes> = []
        for idx in begin...end-1 {
            let attr = self.allItemAttributes[idx]
            if rect.intersects(attr.frame) {
                attrs.append(attr)
            }
        }
        
        return attrs
    }
}

extension DLCollectionViewWaterfallLayout {
    func shortestColumnIndex() -> Int {
        var shortestHeight: Float = MAXFLOAT
        var index: Int = 0
        
        var i = 0
        for column in self.columnHeights {
            let height = column
            if height < shortestHeight {
                index = i
                shortestHeight = height
            }
            i += 1
        }
        
        return index
    }
    
    func longestColumnIndex() -> Int {
       var longestHeight: Float = 0
       var index: Int = 0
       
       var i = 0
       for column in self.columnHeights {
           let height = column
           if height > longestHeight {
               index = i
               longestHeight = height
           }
           i += 1
       }
       
       return index
   }
}
