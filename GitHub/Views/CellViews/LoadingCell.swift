//
//  LoadingCell.swift
//  GitHub
//
//  Created by Rizwan Rafeek on 18/07/2024.
//

import UIKit

class LoadingCell: UITableViewCell {
    @IBOutlet weak var avatarView: UIView!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var descView: UIView!
    @IBOutlet weak var iconView: UIView!
    
    static let identifier = "LoadingCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "LoadingCell", bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        addShimmerAnimation(to: avatarView)
        addShimmerAnimation(to: nameView)
        addShimmerAnimation(to: descView)
        addShimmerAnimation(to: iconView)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.layoutIfNeeded()
    }
    
    private func addShimmerAnimation(to view: UIView) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.colors = [
            UIColor.systemGray5.cgColor,
            UIColor.systemGray4.cgColor,
            UIColor.systemGray5.cgColor
        ]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.repeatCount = .infinity
        animation.duration = 1.5
        gradientLayer.add(animation, forKey: "shimmerAnimation")
        
        view.layer.addSublayer(gradientLayer)
    }
}
