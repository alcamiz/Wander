//
//  TagViewController.swift
//  Wander
//
//  Created by Gabby G on 4/12/24.
//

import UIKit

protocol ModifyTagDelegate {
    func removeTag(tagName: String)
    func addTag(tagName: String)
}

protocol ModifyGameTagsDelegate {
    func setGameTags(newTags: [String])
}

class TagViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ModifyTagDelegate {
    
    var delegate: UIViewController!
    var currentTags: [String]!
    
    @IBOutlet weak var tagTableView: UITableView!
    let tagCellIdentifier = "TagTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tagTableView.delegate = self
        tagTableView.dataSource = self
        print(currentTags!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let gameVC = delegate as! ModifyGameTagsDelegate
        gameVC.setGameTags(newTags: currentTags)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GlobalInfo.tagList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tagTableView.dequeueReusableCell(withIdentifier: tagCellIdentifier, for: indexPath) as! TagTableViewCell
        let row = indexPath.row
        
        let thisTag = GlobalInfo.tagList[row]
        cell.isChecked = currentTags.contains(thisTag)
        cell.tagLabel.text! = thisTag
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tagTableView.deselectRow(at: indexPath, animated: true)
    }
    
    func removeTag(tagName: String) {
        let index = currentTags.firstIndex(of: tagName)
        currentTags.remove(at: index!)
        print(currentTags!)
    }

    func addTag(tagName: String) {
        currentTags.append(tagName)
        print(currentTags!)
    }
}
