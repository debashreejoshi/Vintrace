//
//  StockItemViewController.swift
//  Vintrace
//
//  Created by Debashree Joshi on 30/6/2023.
//

import UIKit
import SafariServices

class StockItemViewController: UIViewController {
    
    @IBOutlet weak var carouselView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var secondaryDescriptionLabel: UILabel!
    @IBOutlet weak var beverageColoredView: UIView!
    @IBOutlet weak var beverageDescriptionLabel: UILabel!
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var unitNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var backBarButton: UIBarButtonItem!
    @IBOutlet weak var moreBarButton: UIBarButtonItem!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    @IBOutlet weak var beveragePropertiesStackView: UIStackView!
    @IBOutlet weak var imageCountLabel: UILabel!
    
    var viewModel = StockItemViewModel()
    
    private let imageNames: [String] = ["wine-1", "wine-2", "wine-3", "wine-4"]
    var images: [UIImage] = []
    private let genericImageName = "generic-1"
    var currentImageIndex: Int = 0
    
    private enum Constant {
        static let minHeaderHeight: CGFloat = 90
        static let maxHeaderHeight: CGFloat = 574
    }
    
    var shouldShowHeader: Bool = true {
        didSet {
            configureNavigationBarAppearance()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.fetchData()
        self.setupCarousel()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBarAppearance()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func configureUI() {
        // Configure table view background color
        tableView.backgroundColor = UIColor(hex: "#F7F7F7")
        
        // Configure header view appearance
        headerView.layer.cornerRadius = 32
        headerView.clipsToBounds = true
        headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(headerViewTapped(_:))))
        
        // Configure navigation bar tap gesture recognizer
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(headerViewTapped(_:)))
        navigationController?.navigationBar.addGestureRecognizer(tapGestureRecognizer)
        
        // Load an array of UIImage objects from an array of image names using compactMap to remove any nil values
        images = imageNames.compactMap { UIImage(named: $0) }
        if images.isEmpty, let image = UIImage(named: genericImageName) {
            images.append(image)
        }
        
        self.updateImageCountLabel()
    }
    
    func updateImageCountLabel() {
        self.imageCountLabel.layer.cornerRadius = 8
        self.imageCountLabel.clipsToBounds = true
        self.imageCountLabel.text = "\(currentImageIndex + 1)/\(images.count)"
    }
    
    // MARK: - Data Fetching
    
    func fetchData() {
        viewModel.fetchData { [weak self] result in
            switch result {
            case .success(let stock):
                self?.handleSuccess(stock)
            case .failure(let error):
                self?.handleError(error)
            }
        }
    }
    
    func handleSuccess(_ stock: Stock) {
        DispatchQueue.main.async {
            self.updateUI(with: stock)
        }
    }
    
    func handleError(_ error: Error) {
        DispatchQueue.main.async {
            print("Error: \(error.localizedDescription)")
            // Show error message to the user
            self.showAlert(title: "Error", message: error.localizedDescription)
        }
    }
    
    @objc func headerViewTapped(_ sth: AnyObject){
        // Expand or collapse header view
        shouldShowHeader.toggle()
        configureNavigationBarAppearance()
    }
    
    private func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        
        if shouldShowHeader {
            appearance.configureWithTransparentBackground()
            navigationItem.title = ""
        } else {
            appearance.configureWithDefaultBackground()
            navigationItem.title = viewModel.stockItem?.code
            
            appearance.backgroundColor =  UIColor(named: "AccentColor")
        }
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance  = appearance
        
        UIView.animate(withDuration: 0.3) {
            self.headerHeightConstraint.constant = self.shouldShowHeader ? Constant.maxHeaderHeight : Constant.minHeaderHeight
            self.view.layoutIfNeeded()
        }
        
        backBarButton.image = shouldShowHeader ? UIImage(named: "BACK") : UIImage(named: "back_clear")
        moreBarButton.image = shouldShowHeader ? UIImage(named: "MORE") : UIImage(named: "more_clear")
        editBarButton.image = shouldShowHeader ? UIImage(named: "EDIT") : UIImage(named: "edit_clear")
    }
    
    private func updateUI(with stock: Stock) {
        // Update UI with stock data
        self.titleLabel.text = stock.code
        self.descriptionLabel.text = stock.description
        self.secondaryDescriptionLabel.text = stock.secondaryDescription
        self.secondaryDescriptionLabel.isHidden = stock.secondaryDescription == nil
        self.ownerNameLabel.text = stock.owner?.name
        self.unitNameLabel.text = stock.unit?.name
        self.configureBeverageProperties(with: stock)
    }
    
    private func configureBeverageProperties(with stock: Stock) {
        // Hide beverage properties stack view if there is no description
        if let beverageProperties = self.viewModel.stockItem?.beverageProperties {
            self.beverageColoredView.layer.cornerRadius = beverageColoredView.bounds.width/2
            self.beverageColoredView.clipsToBounds = true
            self.beverageColoredView.backgroundColor = UIColor(hex: "#\(beverageProperties.colour ?? "")")
            self.beverageDescriptionLabel.text = beverageProperties.description
            
            // Show the stack view
            beveragePropertiesStackView.isHidden = false
        } else {
            // Hide the stack view
            beveragePropertiesStackView.isHidden = true
        }
    }
    
    
    // Method to setup the carousel with images
    private func setupCarousel() {
        let carouselView = UIScrollView(frame: self.carouselView.bounds)
        carouselView.isPagingEnabled = true
        carouselView.showsHorizontalScrollIndicator = false
        carouselView.contentSize = CGSize(width: carouselView.frame.width * CGFloat(images.count), height: carouselView.frame.height)
        carouselView.delegate = self
        
        let content = UIView(frame: CGRect(origin: .zero, size: CGSize(width: carouselView.frame.width * CGFloat(images.count), height: carouselView.frame.height)))
        for (index, image) in images.enumerated() {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFill
            imageView.frame = CGRect(x: carouselView.frame.width * CGFloat(index), y: 0, width: carouselView.frame.width, height: carouselView.frame.height)
            content.addSubview(imageView)
        }
        carouselView.addSubview(content)
        
        self.carouselView.addSubview(carouselView)
    }
    
    
    @IBAction func moreAction(_ sender: Any) {
        guard let url = URL(string: "https://www.vintrace.com") else { return }
        let vc = SFSafariViewController(url: url)
        self.present(vc, animated: true)
    }
    
}

extension StockItemViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Calculate the current index based on the content offset
        currentImageIndex = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        updateImageCountLabel()
    }
}

extension StockItemViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = Section(rawValue: section) else {
            return 0
        }
        
        switch sectionType {
        case .levels:
            return 4
        case .components:
            return viewModel.stockItem?.components?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue:indexPath.section) {
        case .levels:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LevelTableViewCell", for: indexPath) as? LevelTableViewCell else {
                fatalError("Unable to dequeue LabelCell")
            }
            
            let quantity = viewModel.stockItem?.quantity
            let onHand = quantity?.onHand ?? 0
            let committed = quantity?.committed ?? 0
            let ordered = quantity?.ordered ?? 0
            
            switch indexPath.row {
            case 0:
                cell.configure(with: "On hand", value: onHand)
            case 1:
                cell.configure(with: "Committed", value: committed)
            case 2:
                cell.configure(with: "In production", value: ordered)
            case 3:
                let available = onHand + ordered - committed
                cell.configure(with: "Available", value: available)
                cell.quantityNumberLabel.textColor = available == 0 ? .black : available > 0 ? UIColor(named: "AccentColor") : .red
            default:
                break
            }
            
            return cell
        case .components:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ComponentTableViewCell", for: indexPath) as? ComponentTableViewCell else {
                fatalError("Unable to dequeue ComponentCell")
            }
            cell.componentModel = self.viewModel.stockItem?.components?[indexPath.row]
            return cell
            
        case .none:
            fatalError("Invalid section")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 52
    }
}

extension StockItemViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let sectionType = Section(rawValue: indexPath.section) else {
            return
        }
        switch sectionType {
        case .components:
            self.showAlert(title: "Component Selected", message: "You selected a component: \(indexPath.row + 1)")
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionType = Section(rawValue: section) else {
            return nil
        }
        
        return configureHeaderView(for: sectionType)
        
    }
    
    private func configureHeaderView(for section: Section) -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        headerView.backgroundColor = UIColor(hex: "#F7F7F7")
        
        let titleLabel = UILabel(frame: CGRect(x: 16, y: 0, width: 100, height: 40))
        titleLabel.font = UIFont(name: "Montserrat", size: 17)
        titleLabel.text = section == .levels ? "Levels" : "Components"
        headerView.addSubview(titleLabel)
        
        if section == .levels {
            let editButtonWidth: CGFloat = 60
            let editButton = UIButton(type: .system)
            editButton.frame = CGRect(x: headerView.frame.width - editButtonWidth - 40, y: 0, width: editButtonWidth, height: 40)
            editButton.setTitle("Edit", for: .normal)
            editButton.titleLabel?.font =  UIFont(name: "Montserrat", size: 14)
            editButton.setTitleColor(UIColor(named: "AccentColor"), for: .normal)
            editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
            headerView.addSubview(editButton)
        } else {
            let componentsCount = viewModel.stockItem?.components?.count ?? 0
            let countLabel = UILabel(frame: CGRect(x: titleLabel.frame.maxX + 0, y: 0, width: 50, height: 40))
            countLabel.text = "(\(componentsCount))"
            countLabel.textColor = UIColor(hex: "#999999")
            headerView.addSubview(countLabel)
        }
        
        return headerView
    }
    
    @objc private func editButtonTapped() {
        self.showAlert(title: "Edit", message: "This is edit button alert")
    }
}




