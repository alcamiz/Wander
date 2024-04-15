//
//  ContractionView.swift
//  Wander
//
//  Created by Alex Cabrera on 4/2/24.
//

import UIKit

class ContractionView: UIView, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    @IBOutlet var contractionView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var actionButton: UIButton!
    
    var dataList: [String] = []
    var contractionViewId: String?
    
    var numRows = 1
    var numCols = 1
    
    var cellWidth: CGFloat = 1.0
    var cellHeight: CGFloat = 1.0
    
    var wPaddingConst: CGFloat = 4.0
    var hPaddingConst: CGFloat = 2.0
    
    var selectAction: (IndexPath, Bool) -> Void = { _,_ in }
    var selectedIndex: IndexPath?
    
    var buttonAction: () -> Void = {}
    
    let debug = false
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        initSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    func initSubviews() {

        let nib = UINib(nibName: "ContractionView", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        addSubview(contractionView)
        
        contractionView.frame = self.bounds
        contractionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        self.titleLabel.text = "Placeholder"
        self.contractionViewId = UUID().uuidString

        self.collectionView.register(UINib(nibName: "ContractionCell", bundle: nil), forCellWithReuseIdentifier: self.contractionViewId!)
        self.collectionView.allowsSelection = true
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.cornerRadius = 15
        self.layer.borderWidth = 2.5
        self.layer.borderColor = UIColor(hex: "#389eb9").cgColor

    }
    
    func getSelectedData() -> String? {
        if !debug {
            return selectedIndex != nil ? dataList[selectedIndex!.row] : nil
        }
        return nil
    }
    
    func setDataSource(data: [String]) {
        self.dataList = data
        self.collectionView.reloadData()
    }
    
    func autoCellSize() {
        let availableWidth = self.collectionView.bounds.width
        let availableHeight = self.collectionView.bounds.height
        
        let fRows = CGFloat(numRows)
        let fCols = CGFloat(numCols)
        
        self.cellWidth = availableWidth / (fCols + ((fCols - 1) / wPaddingConst))
        self.cellHeight = availableHeight / (fRows + ((fRows - 1) / hPaddingConst))
    }
    
    override func layoutSubviews() {
        self.collectionView.collectionViewLayout.invalidateLayout()
        super.layoutSubviews()
    }
    
    func setCells(numRows: Int, numCols: Int, wPaddingConst: CGFloat?, hPaddingConst: CGFloat?) {
        
        self.numRows = numRows
        self.numCols = numCols
        
        if wPaddingConst != nil {
            self.wPaddingConst = wPaddingConst!
        }
        if hPaddingConst != nil {
            self.hPaddingConst = hPaddingConst!
        }
    }

    func calcHeight(collectionHeight: CGFloat) -> CGFloat {
        let extraSize = self.frame.height - self.collectionView.frame.height
        return collectionHeight + extraSize
    }
    
    func calcNewHeight(numRows: Int) -> CGFloat {
        let fRows = CGFloat(numRows)
        let newHeight = self.cellHeight * (fRows + (fRows - 1) / hPaddingConst)
        self.numRows = numRows
        return calcHeight(collectionHeight: newHeight)
    }
    
    func setSelectionHandler(action: @escaping (IndexPath, Bool) -> Void) {
        self.selectAction = action
    }
    
    @IBAction func performAction(_ sender: Any) {
        self.buttonAction()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !debug {
            return min(self.numRows * self.numCols, dataList.count)
        }
        return self.numRows * self.numCols
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.contractionViewId!, for: indexPath) as! ContractionCell
        cell.mainLabel.font = cell.mainLabel.font.withSize(cell.frame.height * 2/3)
        cell.mainLabel.layer.cornerRadius = cell.frame.height / 2
        
        if self.selectedIndex != indexPath {
            cell.setUnselected()
        } else {
            cell.setSelected()
        }

        // Start - Implementation
        if !debug {
            cell.mainLabel.text = dataList[indexPath.row]
        } else {
            if indexPath.row % 2 == 0 {
                cell.mainLabel.text = "Test #1"
            } else {
                cell.mainLabel.text = "Test #2"
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                if self.selectedIndex != nil {
                    let prevCell = collectionView.cellForItem(at: self.selectedIndex!) as! ContractionCell
                    prevCell.setUnselected()
                }
                
                if self.selectedIndex != indexPath {
                    let newCell = collectionView.cellForItem(at: indexPath) as! ContractionCell
                    newCell.setSelected()
                    self.selectedIndex = indexPath
                } else {
                    self.selectedIndex = nil
                }
            }
            self.selectAction(indexPath, self.selectedIndex != nil)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        self.autoCellSize()
        return CGSize(width: self.cellWidth, height: self.cellHeight)
    }

}
