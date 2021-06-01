
import UIKit

class ProductCollectionViewCell: UICollectionViewCell {
  
  @IBOutlet private var imageView: UIImageView!
  @IBOutlet private var nameLabel: UILabel!
  @IBOutlet private var priceLabel: UILabel!
  @IBOutlet private var badgeImageView: UIImageView!
  
  private var viewModel: ProductViewModel?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  deinit {
    unbindViewModel()
  }
  
  override func didMoveToWindow() {
    defer { super.didMoveToWindow() }
    guard window == nil else {
      return
    }
    
    unbindViewModel()
    
  }
  
  override func prepareForReuse() {
    unbindViewModel()
    
    super.prepareForReuse()
  }
  
  private func unbindViewModel() {
    viewModel?.name.unbind(self)
    viewModel?.image.unbind(self)
    viewModel?.price.unbind(self)
    viewModel?.badge.unbind(self)
  }
  
  @discardableResult
  func configure(with viewModel: ProductViewModel) -> Self {
    unbindViewModel()
    
    self.viewModel = viewModel
    
    viewModel.name.bind(self) { [unowned self] name in
      self.nameLabel.text = name
    }
    
    viewModel.image.bind(self) { [unowned self] image in
      self.imageView.image = image
    }
    
    viewModel.price.bind(self) { [unowned self] string in
      self.priceLabel.attributedText = string
    }
    
    viewModel.badge.bind(self)  { [unowned self] image in
      self.badgeImageView.image = image
    }
    
    return self
  }
  
}
