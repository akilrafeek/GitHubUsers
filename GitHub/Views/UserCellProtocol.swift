//
//  UserCellViewModel.swift
//  GitHub
//
//  Created by Rizwan Rafeek on 18/07/2024.
//

import UIKit

protocol UserCellViewModel {
    var login: String { get }
    var avatarUrl: String { get }
    var hasNote: Bool { get }
    var isSeen: Bool { get }
}

protocol UserCell: UITableViewCell {
    func configure(with viewModel: UserCellViewModel)
}

protocol InvertedAvatarCell: UserCell {
    func invertAvatar()
}