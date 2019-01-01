//
//  ViewController.swift
//  Pinterest
//
//  Created by Németh Gergely on 2018. 12. 19..
//  Copyright © 2018. Németh Gergely. All rights reserved.
//

import UIKit

extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: image!.cgImage!)
    }
}

struct Item {
    let color: UIColor = UIColor(
        red: CGFloat(arc4random_uniform(256))/255,
        green: CGFloat(arc4random_uniform(256))/255,
        blue: CGFloat(arc4random_uniform(256))/255,
        alpha: 1.0
    )
    let height: CGFloat = 80 + CGFloat(arc4random_uniform(5)) * 25
}

class ViewController: UIViewController {

    @IBOutlet weak var headerView: CustomHeader!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    private var items = [Item]()
    @IBOutlet private weak var collectionView: UICollectionView!

    private let translucentPercentage: CGFloat = 0.5
    private let overlap: CGFloat = 80.0

    override func viewDidLoad() {
        super.viewDidLoad()
        (collectionView.collectionViewLayout as? CustomLayout)?.delegate = self
        let newHeight = headerHeightConstraint.constant
        collectionView.contentInset = UIEdgeInsets(top: newHeight + newHeight/4, left: 40, bottom: 16, right: 40)
        collectionView.contentInsetAdjustmentBehavior = .never
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        headerView.minimumHeigth = navigationController?.navigationBar.frame.maxY ?? 64
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.appendAll()
        }
    }

    private func appendAll() {
        items = (0...10).map { _ in Item() }
        let indices = (0...10).map { IndexPath(item: $0, section: 0) }

        collectionView.performBatchUpdates({ [weak self] in
            self?.collectionView.insertItems(at: indices)
            }, completion: nil)
    }

    private func appendItem() {
        let index = items.count//Int(arc4random_uniform(UInt32(items.count+1)))
        items.insert(Item(), at: index)
        let newIndices = [IndexPath(item: index, section: 0)]
        collectionView.performBatchUpdates({ [weak self] in
            self?.collectionView.insertItems(at: newIndices)
            }, completion: nil)
        collectionView.scrollToItem(at: newIndices[0], at: .centeredVertically, animated: true)
    }

    @IBAction func removeButtonTap(_ sender: Any) {
        guard items.count != 0 else { return }
        let index = items.count - 1//Int(arc4random_uniform(UInt32(items.count)))
        let newIndices =  [IndexPath(item: index, section: 0)]
        items.remove(at: index)

        collectionView.performBatchUpdates({ [weak self] in
            self?.collectionView.deleteItems(at: newIndices)
            }, completion: nil)
    }
    @IBAction func addButtonTap(_ sender: Any) {
        appendItem()
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath)
        cell.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        (cell as? CustomCell)?.titleLabel.text = "\(indexPath.item)"
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y
        let newHeight = max(0, -contentOffset)
        let originalHeight = scrollView.contentInset.top
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: newHeight, left: 0, bottom: 0, right: 0)
        if newHeight != headerHeightConstraint.constant {
            let alpha = max(0, (translucentPercentage - min(originalHeight, newHeight) / originalHeight) / translucentPercentage)
            navigationController?.navigationBar.shadowImage = alpha == 1.0 ? UINavigationBar().shadowImage : UIImage()
            headerHeightConstraint.constant = newHeight + newHeight/4
        }
        headerView.setGradient(x: newHeight/originalHeight)
    }
}

extension ViewController: CustomLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        return items[indexPath.item].height
    }
}
