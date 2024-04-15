//
//  FilterView.swift
//  Wander
//
//  Created by Alex Cabrera on 4/4/24.
//

import UIKit

class FilterView: UIViewController {

    @IBOutlet weak var domainView: ContractionView!
    @IBOutlet weak var sortView: ContractionView!
    @IBOutlet weak var tagView: ContractionView!
    
    @IBOutlet weak var domainHeight: NSLayoutConstraint!
    @IBOutlet weak var sortHeight: NSLayoutConstraint!
    @IBOutlet weak var tagHeight: NSLayoutConstraint!
    
    var resultView: NewResult?
    
    var domainList: [String] = GlobalInfo.domainList
    var sortList: [String] = GlobalInfo.sortList
    var tagList: [String] = GlobalInfo.tagList
    
    let domainRows = 1
    let domainCols = 3
    
    let sortRows = 1
    let sortCols = 2
    
    let tagRows = 4
    let tagCols = 3
    
    var domainRowsExpanded: Int = 0
    var sortRowsExpanded: Int = 0
    var tagRowsExpanded: Int = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        domainView.titleLabel.text = "Domains"
        domainView.setCells(numRows: domainRows, numCols: domainCols, wPaddingConst: 5.5, hPaddingConst: 2.0)
        domainView.autoCellSize()
        domainView.setDataSource(data: domainList)
        domainView.actionButton.setTitle("<< All domains >>", for: .normal)
//        domainView.buttonAction = tagAction
        domainRowsExpanded = domainList.count / domainCols
        
        sortView.titleLabel.text = "Sort"
        sortView.setCells(numRows: sortRows, numCols: sortCols, wPaddingConst: 10.0, hPaddingConst: 2.0)
        sortView.autoCellSize()
        sortView.setDataSource(data: sortList)
        sortView.actionButton.setTitle("<< All sorts >>", for: .normal)
//        sortView.buttonAction = sortAction
        sortRowsExpanded = sortList.count / sortCols
        
        tagView.titleLabel.text = "Tags"
        tagView.setCells(numRows: tagRows, numCols: tagCols, wPaddingConst: 9.0, hPaddingConst: 2.0)
        tagView.autoCellSize()
        tagView.setDataSource(data: tagList)
        tagView.actionButton.setTitle("See more >>", for: .normal)
        tagView.buttonAction = tagAction
        tagRowsExpanded = tagList.count / tagCols
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        domainView.actionButton.titleLabel?.font = domainView.actionButton.titleLabel?.font.withSize(15.0)
        sortView.actionButton.titleLabel?.font = sortView.actionButton.titleLabel?.font.withSize(15.0)
        tagView.actionButton.titleLabel?.font = tagView.actionButton.titleLabel?.font.withSize(15.0)
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
        self.tagHeight.constant = self.tagView.calcNewHeight(numRows: tagRowsExpanded)
        tagView.actionButton.setTitle("See less <<", for: .normal)
        self.tagView.collectionView.reloadData()
    }
    
    func retractTag() {
        tagHeight.constant = tagView.calcNewHeight(numRows: tagRows)
        tagView.actionButton.setTitle("See more >>", for: .normal)
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
        self.sortHeight.constant = self.sortView.calcNewHeight(numRows: 20)
        sortView.actionButton.setTitle("See less <<", for: .normal)
        self.sortView.collectionView.reloadData()
    }
    
    func retractSort() {
        sortHeight.constant = sortView.calcNewHeight(numRows: sortRows)
        sortView.actionButton.setTitle("See more >>", for: .normal)
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
