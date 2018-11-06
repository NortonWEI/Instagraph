//
//  SuggestionViewController.swift
//  Instagraph
//
//  Created by Margareta  Hardiyanti on 11/09/18.
//  Copyright © 2018 Wenzhou Wei. All rights reserved.
//

import UIKit
import SnapKit

class SuggestionViewController: UIViewController , UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var searchResultContainerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchVC : SearchViewController!
    var userSuggestions: [String: FirebaseUser] = [:]
    var userSources: [String: String] = [:]
    var stopSuggesting = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "Billabong", size: 30)!]
        
        self.searchBar.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "usercell")
        self.titleLabel.textColor = ColorObject.sharedInstance.darkGray1
        self.titleLabel.font = FontObject.sharedInstance.bodyCopy1Bold
        self.titleLabel.text = "Suggestions for you"
        self.searchResultContainerView.backgroundColor = UIColor.red
        self.searchResultContainerView.isHidden = true
        self.setupSearchResultContainment()
        
        reloadSuggestions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        TabIndex.currentSelectedIndex = 1;
    }

    // Add suggestion to table and start loading profile image
    func onNewSuggestionFound(user: FirebaseUser, source: String) {
        self.userSuggestions[user.uid] = user
        self.userSources[user.uid] = source
        
        UserManager.share.getProfileImage(user: user, callback: {(image, error) in
            if image != nil {
                user.image = image!
            }
            
            self.tableView.reloadData()
        })
        
        self.tableView.reloadData()
    }
    
    func shouldStopSuggesting() -> Bool {
        return self.stopSuggesting
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
        self.searchResultContainerView.isHidden = false
        self.stopSuggesting = true // Stop suggesting
        
        self.addChildViewController(searchVC)
        self.searchVC.didMove(toParentViewController: self)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.text = searchText.lowercased() // Lowercase search text for searching
        
        UserManager.share.searchUsers(name: searchBar.text!, callback: { (users, error) in
            self.searchVC.updateSearchResults(users: users, error: error)
        })
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = false
        self.searchBar.endEditing(true)
        self.searchResultContainerView.isHidden = true
        self.stopSuggesting = false // Continue/begin suggesting

        self.searchVC.removeFromParentViewController()
        
        // Clear and reload suggestions
        reloadSuggestions()
    }
    
    func reloadSuggestions() {
        self.userSuggestions = [:]
        self.tableView.reloadData()
        UserManager.share.startUserSuggestions(onNewSuggestionFound: self.onNewSuggestionFound, shouldStopSearching: self.shouldStopSuggesting)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userSuggestions.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "usercell", for: indexPath) as! UserTableViewCell
        
        // Pass user object to cell
        let user = Array(self.userSuggestions.values)[indexPath.row]
        cell.setAvatar(user: user, suggestionSource: self.userSources[user.uid]!)
        cell.avatarSelected = {
            self.openUserVC(uid: user.uid)
        }

        return cell
    }
    
    func setupSearchResultContainment() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        self.searchVC = mainStoryboard.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController
        self.searchResultContainerView.addSubview(self.searchVC.view)
        self.searchVC.view.snp.makeConstraints { (make) -> Void in
            make.bottom.equalTo(50)
            make.top.equalTo(0)
            make.leading.equalTo(0)
            make.trailing.equalTo(0)
        }
    }
    
    public func openUserVC (uid : String) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        viewController.setupUserUID(uid: uid)
        viewController.isEnterFromSuggestion = true
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
   

}
