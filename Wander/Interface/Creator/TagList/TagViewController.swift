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

class TagViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ModifyTagDelegate {
    
    var delegate: GameView!
    var currentTags: [String]!
    
    @IBOutlet weak var tagTableView: UITableView!
    let tagCellIdentifier = "TagTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tagTableView.delegate = self
        tagTableView.dataSource = self
        print(currentTags!)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GlobalInfo.tagList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tagTableView.dequeueReusableCell(withIdentifier: tagCellIdentifier, for: indexPath) as! TagTableViewCell
        let row = indexPath.row
        
        let thisTag = GlobalInfo.tagList[row]
        var cellTitle = thisTag
        cell.isChecked = currentTags.contains(thisTag)
        cell.tagLabel.text! = cellTitle
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: tagCellIdentifier, for: indexPath) as! TagTableViewCell
//        let row = indexPath.row
        
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
