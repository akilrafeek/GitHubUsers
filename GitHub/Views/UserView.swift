//
//  ViewController.swift
//  GitHub
//
//  Created by Akil Rafeek on 16/06/2024.
//

import UIKit
import SwiftUI
import CoreData

class UserView: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var managedContext: NSManagedObjectContext!
    var viewModel: UserViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = UserViewModel(managedContext: managedContext)
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UserCellView.nib(), forCellReuseIdentifier: UserCellView.identifier)
        
        viewModel.onUserFetched = { [weak self] in
            self?.tableView.reloadData()
        }
        viewModel.fetchUser()
    }


}

extension UserView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.user.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCellView.identifier, for: indexPath) as! UserCellView
        let user = viewModel.user[indexPath.row]
        ImageLoader.loadImage(from: user.value(forKey: "avatarUrl") as! String, into: cell.userImageView)
        cell.userNameLabel.text = user.value(forKey: "login") as? String
        cell.userDetailLabel.text = "BOss"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected")
        let selectedUser = viewModel.user[indexPath.row]
        let username = selectedUser.value(forKey: "login") as? String ?? ""
        let userId = selectedUser.value(forKey: "userId") as? Int16 ?? -1
        var userProfileVC = UserProfileView(username: username, userId: userId)
        let hostingController = UIHostingController(rootView: userProfileVC)
        self.navigationController?.pushViewController(hostingController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
