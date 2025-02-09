//
//  SearchFlow.swift
//  Wander
//
//  Created by Alex Cabrera on 3/27/24.
//

import UIKit

class SearchFlow: UIViewController, UISearchControllerDelegate, UISearchBarDelegate {

    
    var searchControl: UISearchController = UISearchController()
    
    let resultView = {
        return ResultView(nibName: "ResultView", bundle: nil)
    }()
    
    let filterView = {
        return FilterView(nibName: "FilterView", bundle: nil)
    }()
    
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search"
        
        searchControl = UISearchController(searchResultsController: resultView)
        searchControl.delegate = self
        searchControl.searchBar.delegate = self
        searchControl.showsSearchResultsController = false
        
        searchControl.searchBar.tintColor = Color.primary
        searchControl.searchBar.autocapitalizationType = .none
        searchControl.searchBar.autocorrectionType = .no
        searchControl.searchBar.showsBookmarkButton = true
        searchControl.searchBar.setImage(UIImage(systemName: "line.3.horizontal.decrease.circle"), for: .bookmark, state: .normal)
        
        let searchText = searchControl.searchBar.value(forKey: "searchField") as? UITextField
        searchText?.backgroundColor = UIColor.systemGray4
        self.navigationItem.searchController = searchControl
        
        resultView.localSuperView = self
        messageLabel.textColor = .lightGray
        messageLabel.text = "Search for something, dummy"
    }
    
    override func viewDidAppear(_ animated: Bool) {

        // Make search bar active on initial load
        DispatchQueue.main.async {
            self.searchControl.searchBar.becomeFirstResponder()
        }
        
        resultView.fixSelectedRow()
    }
    
    // Animates changes in safe area due to search bar
    override func viewSafeAreaInsetsDidChange() {
        self.view.layoutIfNeeded()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let results = searchControl.searchResultsController as! ResultView
        results.query = searchBar.text ?? ""
        Task {
            await results.reloadQuery()
            searchControl.showsSearchResultsController = true
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchControl.showsSearchResultsController = false
        self.navigationController?.popViewController(animated: true)
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        filterView.resultView = self.resultView
        if let presentationController = filterView.presentationController as? UISheetPresentationController {
            presentationController.detents = [.medium()]
        }
        self.present(filterView, animated: true)
    }
    

}
