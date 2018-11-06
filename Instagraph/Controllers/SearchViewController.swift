//
//  SearchViewController.swift
//  Instagraph
//
//  Created by Margareta  Hardiyanti on 11/09/18.
//  Copyright © 2018 Wenzhou Wei. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    private var users: [FirebaseUser] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "usercell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func updateSearchResults(users: [FirebaseUser], error: Error?) {
        self.users = users
    
        for user in users {
            UserManager.share.getProfileImage(user: user, callback: {(image, error) in
                if image != nil {
                    user.image = image!
                }
                
                self.tableView.reloadData()
            })
        }
        
        self.tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "usercell", for: indexPath) as! UserTableViewCell

        // Pass user object to cell
        let user = self.users[indexPath.row]
        cell.setAvatar(user: user, suggestionSource: nil)
        cell.avatarSelected = {
            self.openUserVC(uid: user.uid)
        }
        
        return cell
    }
    
    public func openUserVC (uid : String) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        viewController.setupUserUID(uid: uid)
        
        self.navigationController?.pushViewController(viewController, animated: false)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
