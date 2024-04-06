//
//  FilterView.swift
//  Wander
//
//  Created by Alex Cabrera on 4/4/24.
//

import UIKit

class FilterView: UIViewController {

    @IBOutlet weak var tagView: ContractionView!
    @IBOutlet weak var sortView: ContractionView!
    
    @IBOutlet weak var tagHeight: NSLayoutConstraint!
    @IBOutlet weak var sortHeight: NSLayoutConstraint!
    
    var resultView: ResultView?
    
    var tagList: [String] = []
    var sortList: [String] = []
    
    let tagRows = 4
    let tagCols = 3
    
    let sortRows = 1
    let sortCols = 4
    
    var tagRowsExpanded: Int = 0
    var sortRowsExpanded: Int = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tagView.titleLabel.text = "Tags"
        
        tagView.setCells(numRows: tagRows, numCols: tagCols, wPaddingConst: 5.5, hPaddingConst: 2.0)
        tagView.autoCellSize()
        tagView.setDataSource(data: tagList)
        tagView.actionButton.setTitle("See more >>", for: .normal)
        tagView.buttonAction = tagAction
        tagRowsExpanded = tagList.count / tagCols
        
        sortView.titleLabel.text = "Sort"
        sortView.setCells(numRows: sortRows, numCols: sortCols, wPaddingConst: 4.0, hPaddingConst: 2.0)
        sortView.autoCellSize()
        sortView.setDataSource(data: sortList)
        sortView.actionButton.setTitle("See more >>", for: .normal)
        sortView.buttonAction = sortAction
        sortRowsExpanded = sortList.count / sortCols
        
        // TODO: Retrieve tag data
        // TODO: Retrieve sort data
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resultView?.selectedFilter = tagView.getSelectedData()
        resultView?.selectedSort = sortView.getSelectedData()
        resultView?.tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.retractTag()
        self.retractSort()
    }
    
    func tagAction() {
        if self.tagView.numRows != self.tagRows {
            self.retractTag()
        } else {
            self.expandTag()
        }
    }
    
    func expandTag() {
        self.tagHeight.constant = self.tagView.calcNewHeight(numRows: 30)
        tagView.actionButton.setTitle("See less >>", for: .normal)
        self.tagView.collectionView.reloadData()
    }
    
    func retractTag() {
        tagHeight.constant = tagView.calcNewHeight(numRows: tagRows)
        tagView.collectionView.reloadData()
    }
    
    func sortAction() {
        if self.sortView.numRows != self.sortRows {
            self.retractSort()
        } else {
            self.expandSort()
        }
    }
    
    func expandSort() {
        self.sortHeight.constant = self.sortView.calcNewHeight(numRows: 30)
        sortView.actionButton.setTitle("See less >>", for: .normal)
        self.sortView.collectionView.reloadData()
    }
    
    func retractSort() {
        sortHeight.constant = sortView.calcNewHeight(numRows: sortRows)
        sortView.collectionView.reloadData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
