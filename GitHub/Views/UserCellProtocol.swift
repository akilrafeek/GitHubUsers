//
//  UserCellViewModel.swift
//  GitHub
//
//  Created by Akil Rafeek on 18/07/2024.
//

import UIKit

protocol UserCellViewModel {
    var login: String { get }
    var note: String { get }
    var avatarUrl: String { get }
    var hasNote: Bool { get }
    var isSeen: Bool { get }
}

protocol UserCell: UITableViewCell {
    func configure(with viewModel: UserCellViewModel, isinverted: Bool)
}
