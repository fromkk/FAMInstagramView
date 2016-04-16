//
//  ViewController.swift
//  FAMInstagramView
//
//  Created by Kazuya Ueoka on 2016/04/16.
//  Copyright © 2016年 fromKK. All rights reserved.
//

import UIKit

public class FAMInstagramLayout :UICollectionViewFlowLayout
{
    private static let margin :CGFloat = 8.0
    override init() {
        super.init()
        self._commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self._commonInit()
    }
    
    var _didSet :Bool = false
    private func _commonInit()
    {
        if _didSet
        {
            return
        }
        _didSet = true
        
        self.minimumLineSpacing = self.dynamicType.margin
        self.minimumInteritemSpacing = self.dynamicType.margin
        self.scrollDirection = UICollectionViewScrollDirection.Horizontal
    }
    
    public override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let width :CGFloat = (self.itemSize.width + self.dynamicType.margin)
        let offset :CGPoint = CGPoint(x: (self.collectionView?.contentOffset.x ?? 0.0) + (self.collectionView?.contentInset.left ?? 0.0), y: self.collectionView?.contentOffset.y ?? 0.0)
        let currentPage :CGFloat = offset.x / width
        let maxPage :CGFloat = (self.collectionView?.contentSize.width ?? 0.0) / width
        
        var nextPage :CGFloat
        if 0.2 > abs(velocity.x)
        {
            nextPage = (maxPage > round(currentPage)) ? round(currentPage) : floor(currentPage)
        } else
        {
            nextPage = (velocity.x > 0.0 && maxPage > ceil(currentPage)) ? ceil(currentPage) : floor(currentPage)
        }
        
        return CGPoint(x: nextPage * width - (self.collectionView?.contentInset.left ?? 0.0), y: proposedContentOffset.y)
    }
}

public class FAMInstagramCell :UICollectionViewCell
{
    public static let cellIdentifier :String = "instagramCellIdentifier"
    public lazy var imageView :UIImageView = {
        let result :UIImageView = UIImageView()
        result.contentMode = .ScaleAspectFit
        return result
    }()
    public var item :FAMInstagramItem? {
        didSet
        {
            self.imageView.image = nil
            if let lowResolution :FAMInstagramImage = self.item?.lowResolution, let url :String = lowResolution.url
            {
                self.task = FAMImageLoader.loadImage(url, complete: { (image :UIImage?) in
                    self.imageView.image = image
                })
            }
        }
    }
    public var task :NSURLSessionTask?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self._commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self._commonInit()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        self.imageView.frame = self.bounds
    }
    
    private var _didSet :Bool = false
    private func _commonInit()
    {
        if _didSet
        {
            return
        }
        
        _didSet = true
        self.backgroundColor = UIColor.clearColor()
        self.contentView.addSubview(self.imageView)
    }
    
    public func resume()
    {
        self.task?.resume()
    }
    
    public func cancel()
    {
        self.task?.cancel()
    }
}

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var items :[FAMInstagramItem] = []
    lazy var layout :FAMInstagramLayout = {
        let result :FAMInstagramLayout = FAMInstagramLayout()
        result.itemSize = CGSize(width: 200.0, height: self.view.frame.size.height)
        return result
    }()
    
    lazy var collectionView :UICollectionView = {
        let result :UICollectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: self.layout)
        result.registerClass(FAMInstagramCell.self, forCellWithReuseIdentifier: FAMInstagramCell.cellIdentifier)
        result.delegate = self
        result.dataSource = self
        result.backgroundColor = UIColor.clearColor()
        return result
    }()
    
    override func loadView() {
        super.loadView()
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.collectionView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FAMInstagramApis.fetch(.userMediaRecent, userId: FAMInstagramConfiguration.UserId.rawValue) { (result, error) in
            guard let data :[Dictionary<String, AnyObject>] = result?["data"] as? [Dictionary<String, AnyObject>] else
            {
                print("failed")
                return
            }
            
            self.items = data.map {
                FAMInstagramItem.itemFromDictionary($0)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.collectionView.reloadData()
            })
        }
    
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.collectionView.frame = self.view.bounds
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell :FAMInstagramCell = collectionView.dequeueReusableCellWithReuseIdentifier(FAMInstagramCell.cellIdentifier, forIndexPath: indexPath) as! FAMInstagramCell
        cell.item = self.items[indexPath.row]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        (cell as? FAMInstagramCell)?.resume()
    }
    
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        (cell as? FAMInstagramCell)?.cancel()
    }
}

