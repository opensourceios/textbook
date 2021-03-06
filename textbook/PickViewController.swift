//
//  PickViewController.swift
//  textbook
//
//  Created by John Wong on 4/22/15.
//  Copyright (c) 2015 John Wong. All rights reserved.
//

import UIKit

class PickViewController: UICollectionViewController {
    
    struct StoryBoard {
        struct Cells {
            static let cell = "Cell"
        }
        
        struct SectionHeader {
            static let Identifier = "SectionHeader"
            static let LabelTag = 100
        }
        
        struct Segues {
//            static let showDetail = "showDetail"
        }
    }

    var categoryRequest = CategoryRequest()
    var categoryItems = Array<CategoryItem>()
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.segmentedControl.hidden = true
        self.segmentedControl.addTarget(self, action: Selector("onSegmentedControlChanged"), forControlEvents: UIControlEvents.ValueChanged)
        self.reloadData()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.cancelSGProgress()
    }
    
    func reloadData() {
        self.categoryRequest.loadWithCompletion(
            {
                [unowned self](dict, error) -> Void in
                if let dict = dict {
                    self.categoryItems = CategoryItem.arrayWithDict(dict)
                    self.reloadViews()
                } else {
                    AppConfiguration.showError("数据加载失败", subtitle: error?.localizedDescription)
                }
            }, progress: {
                [unowned self](percent) -> Void in
                self.navigationController?.setSGProgressPercentage(percent, andTitle: "加载中...")
            })
    }
    
    func reloadViews() {
        segmentedControl.removeAllSegments()
        segmentedControl.hidden = false
        for category in categoryItems {
            segmentedControl.insertSegmentWithTitle(category.name, atIndex: segmentedControl.numberOfSegments, animated: true)
        }        
        segmentedControl.selectedSegmentIndex = 0
        self.collectionView?.reloadData()
    }
    
    func onSegmentedControlChanged() {
        self.collectionView?.contentOffset = CGPoint(x: 0, y: 0)
        self.collectionView?.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if categoryItems.count > segmentedControl.selectedSegmentIndex {
            return categoryItems[segmentedControl.selectedSegmentIndex].items.count
        } else {
            return 0
        }
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryItems[segmentedControl.selectedSegmentIndex].items[section].rows.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(StoryBoard.Cells.cell, forIndexPath: indexPath) as! CategoryCell
        cell.setItem(categoryItems[segmentedControl.selectedSegmentIndex].items[indexPath.section].rows[indexPath.row])
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: StoryBoard.SectionHeader.Identifier, forIndexPath: indexPath) 
        let label = header.viewWithTag(StoryBoard.SectionHeader.LabelTag) as? UILabel
        label?.text = categoryItems[segmentedControl.selectedSegmentIndex].items[indexPath.section].header
        return header
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let item = categoryItems[segmentedControl.selectedSegmentIndex].items[indexPath.section].rows[indexPath.row]
        UserDefaults.setObject(item, forKey: UserDefaults.Keys.selectedBook)
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: AppConfiguration.Notifications.BookUpdate, object: nil))
        self.navigationController?.popViewControllerAnimated(true)
    }

}
