//
//  FilterView.swift
//  Wander
//
//  Created by Alex Cabrera on 4/4/24.
//

import UIKit

class FilterView: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var sortHeight: NSLayoutConstraint!
    @IBOutlet weak var tagHeight: NSLayoutConstraint!
    
    @IBOutlet weak var sortView: UICollectionView!
    @IBOutlet weak var tagView: UICollectionView!
    
    var resultView: ResultView?
    
    let sortList: [String] = GlobalInfo.sortList
    let tagList: [String] = GlobalInfo.tagList
    
    let maxRows = 2
    let maxCols = 3
    
    var selectedSort: IndexPath?
    var selectedTag: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sortView.accessibilityIdentifier = "sortView"
        tagView.accessibilityIdentifier = "tagView"
        
        sortView.register(UINib(nibName: "TagCell", bundle: nil), forCellWithReuseIdentifier: "FilterCell")
        tagView.register(UINib(nibName: "TagCell", bundle: nil), forCellWithReuseIdentifier: "FilterCell")
        
        sortView.delegate = self
        sortView.dataSource = self
        
        tagView.delegate = self
        tagView.dataSource = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if selectedSort != nil {
            resultView?.selectedSort = sortList[selectedSort!.row]
        }
        if selectedTag != nil {
            resultView?.selectedFilter = tagList[selectedTag!.row]
        }
        resultView?.tableView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.accessibilityIdentifier {
            case "sortView":
                guard sortList.count > 0 else {
                    return 1
                }
                return sortList.count
            case "tagView":
                guard tagList.count > 0 else {
                    return 1
                }
                return tagList.count
            default:
                return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as! TagCell
        cell.layer.cornerRadius = (collectionView.frame.height / 2) - 2 * cell.layer.borderWidth

        switch collectionView.accessibilityIdentifier {
            case "sortView":
                guard sortList.count > 0 else {
                    cell.labelView.text = "Empty"
                    break
                }
                cell.labelView.text = sortList[indexPath.row]
            case "tagView":
                guard tagList.count > 0 else {
                    cell.labelView.text = "Empty"
                    break
                }
                cell.labelView.text = tagList[indexPath.row]
            default:
                break
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch collectionView.accessibilityIdentifier {
            case "sortView":
                handleSelection(outIndex: &selectedSort, indexPath: indexPath, collectionView: collectionView)
            case "tagView":
                handleSelection(outIndex: &selectedTag, indexPath: indexPath, collectionView: collectionView)
            default:
                break
        }
        
    }
    
    func handleSelection(outIndex: inout IndexPath?, indexPath: IndexPath, collectionView: UICollectionView) {
        
        var prevSelected = outIndex
    
        UIView.animate(withDuration: 0.3) {
            if prevSelected != nil {
                let prevCell = collectionView.cellForItem(at: prevSelected!) as! TagCell
                prevCell.setUnselected()
            }
            
            let newCell = collectionView.cellForItem(at: indexPath) as! TagCell

            if indexPath != prevSelected {
                newCell.setSelected()
                prevSelected = indexPath

            } else {
                prevSelected = nil
            }
        }
        
        outIndex = prevSelected
    }

}
