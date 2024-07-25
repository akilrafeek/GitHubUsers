//
//  ViewController.swift
//  GitHub
//
//  Created by Akil Rafeek on 16/06/2024.
//

import UIKit
import CoreData
import Combine
import SwiftUI

class UserView: UITableViewController {

    private var viewModel: UserViewModel!
    private let searchController = UISearchController(searchResultsController: nil)
    private let offlineView = OfflineView()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupTableView()
        setupSearchBar()
        setupViewModel()
        setupOfflineView()
        setupRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UserCellView.nib(), forCellReuseIdentifier: UserCellView.identifier)
        tableView.register(LoadingCell.nib(), forCellReuseIdentifier: LoadingCell.identifier)
    }
    
    private func setupSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Users"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func setupViewModel() {
        viewModel = UserViewModel(coreDataManager: CoreDataManager.shared, networkManager: NetworkManager.shared)
        viewModel.onUserFetched = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.refreshControl?.endRefreshing()
            }
        }
        viewModel.loadUserFromLocal()
    }
    
    private func setupOfflineView() {
        offlineView.translatesAutoresizingMaskIntoConstraints = false
        offlineView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        tableView.tableHeaderView = offlineView
        offlineView.isHidden = true
        
        viewModel.$isOffline
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isOffline in
                self?.offlineView.isHidden = !isOffline
                self?.tableView.tableHeaderView = isOffline ? self?.offlineView : nil
            }
            .store(in: &cancellables)
    }
    
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    @objc private func refreshData() {
        viewModel.onUserFetched = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.refreshControl?.endRefreshing()
            }
        }
        viewModel.loadUserFromLocal()
    }
}

extension UserView {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.isLoading ? 0 : viewModel.numberOfUsers
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.isLoading {
            let cell =  tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath) as! LoadingCell
            return cell
        }
        
        guard let cell =  tableView.dequeueReusableCell(withIdentifier: "UserCellView", for: indexPath) as? UserCellView else {
            fatalError("Unable to dequeue UserCellView")
        }
        
        let user = viewModel.user(at: indexPath.row)
        let isInverted = (indexPath.row + 1) % 4 == 0
        cell.configure(with: user, isInverted: isInverted)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = viewModel.user(at: indexPath.row)
        let userProfileViewModel = UserProfileViewModel(userLogin: user.login, coreDataManager: CoreDataManager.shared, networkManager: NetworkManager.shared)
        let userProfileView = UserProfileView(viewModel: userProfileViewModel)
        let hostingController = UIHostingController(rootView: userProfileView)
        self.navigationController?.pushViewController(hostingController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height * 1.5 {
            viewModel.fetchMoreUser()
        }
    }
}

extension UserView: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            viewModel.searchUsers(with: searchText)
        } else {
            viewModel.resetSearch()
        }
    }
}
