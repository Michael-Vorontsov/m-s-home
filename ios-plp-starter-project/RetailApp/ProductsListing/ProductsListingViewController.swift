
import UIKit

final class ProductsListingViewController: UIViewController {
  
  @IBOutlet private var collectionView: UICollectionView!
  
  var viewModel: ProductsListingViewModel! {
    didSet {
      oldValue?.cellItems.unbind(self)
      viewModel.cellItems.bind(self) { [unowned self] _ in
        guard self.isViewLoaded else { return }
        
        self.collectionView.reloadData()
      }
    }
  }
  
  deinit {
    viewModel.cellItems.unbind(self)
  }
  
  override func viewDidLoad() {
    let cellNib = UINib(nibName: Cells.nibName, bundle: nil)
    collectionView.register(cellNib, forCellWithReuseIdentifier: Cells.reuseId)
    
    super.viewDidLoad()
    
    viewModel.loadProducts()
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
      var cellWidth = view.bounds.width
      
      cellWidth -= collectionView.contentInset.left + collectionView.contentInset.right
      cellWidth -= layout.sectionInset.left + layout.sectionInset.right
      cellWidth -= layout.minimumInteritemSpacing
      
      cellWidth = cellWidth / 2
      
      layout.itemSize = CGSize(
        width: cellWidth,
        height: cellWidth * 2
      )
    }
  }
}

extension ProductsListingViewController: UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.cellItems.value.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let reuseCell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.reuseId, for: indexPath)
    guard
      let cell = reuseCell as? ProductCollectionViewCell,
      viewModel.cellItems.value.count > indexPath.item
    else { return reuseCell }
    
    let productViewModel = viewModel.cellItems.value[indexPath.item]
    productViewModel.loadImage()
    
    return cell.configure(with: productViewModel)
  }
}

extension ProductsListingViewController: UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard
      viewModel.cellItems.value.count > indexPath.item
    else { return }
    
    let productViewModel = viewModel.cellItems.value[indexPath.item]
    productViewModel.didSelected.value = Void()
  }
  
}

private enum Cells {
  static let reuseId = "ProductCell"
  static let nibName = "ProductCollectionViewCell"
}
