//
//  UserCellView.swift
//  GitHub
//
//  Created by Akil Rafeek on 16/06/2024.
//

import UIKit

class UserCellView: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userDetailLabel: UILabel!
    @IBOutlet weak var noteIcon: UIImageView!
    static let identifier = "UserCellView"
    
    private var imageURL: URL?
    private var shouldInvertImage: Bool = false
    
    static func nib() -> UINib {
        return UINib(nibName: "UserCellView", bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.layoutIfNeeded()
        userImageView.image = nil
        imageURL = nil
        shouldInvertImage = false
        contentView.alpha = 1
    }
    
    func configure(with viewModel: UserCellViewModel, isInverted: Bool) {
        userNameLabel.text = viewModel.login
        userDetailLabel.text = viewModel.note
        noteIcon.isHidden = !viewModel.hasNote
        contentView.alpha = viewModel.isSeen ? 0.5 : 1.0
        shouldInvertImage = isInverted

        
        imageURL = URL(string: viewModel.avatarUrl)
        loadImage()
    }
    
    private func loadImage() {
        guard let url = imageURL else { return }
        
        ImageLoader.shared.loadImage(from: url) { [weak self] image in
            guard let self = self, self.imageURL == url else { return }
            
            DispatchQueue.main.async {
                if self.shouldInvertImage, let invertedImage = self.inverted(image) {
                    self.userImageView.image = invertedImage
                } else {
                    self.userImageView.image = image
                }
            }
        }
    }
    
    func inverted(_ image: UIImage?) -> UIImage? {
        guard let cgImage = image?.cgImage else { return nil }
            
        let ciImage = CIImage(cgImage: cgImage)
        guard let filter = CIFilter(name: "CIColorInvert") else { return nil }
        
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        guard let outputImage = filter.outputImage else { return nil }
        
        let context = CIContext(options: nil)
        guard let invertedCGImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        
        return UIImage(cgImage: invertedCGImage)
    }
    
}
