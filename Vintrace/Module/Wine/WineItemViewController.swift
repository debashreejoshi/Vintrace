//
//  ViewController.swift
//  Vintrace
//
//  Created by Debashree Joshi on 30/6/2023.
//

import UIKit
import SafariServices

class WineItemViewController: UIViewController {
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var carouselView: UIView!
    @IBOutlet weak var wineImageView: UIImageView!
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
    
    
    var shouldShowHeader: Bool = true
    
    private let viewModel = WineItemViewModel()
    
    let imageNames: [String] = ["wine-1", "wine-2", "wine-3", "wine-4"]
    // Create an empty array to store the images
    var images: [UIImage] = []
    let genericImageName = "generic-1"
    
    private enum Constant {
        static let minHeaderHeight: CGFloat = 90
        static let maxHeaderHeight: CGFloat = 574
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor(hex: "#F7F7F7")
        self.viewModel.fetchData(completion: handleFetchResult)
        self.headerView.layer.cornerRadius = 32
        self.headerView.clipsToBounds = true
        self.headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Self.somethingWasTapped(_:))))
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance  = appearance
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(Self.somethingWasTapped(_:)))
        self.navigationController?.navigationBar.addGestureRecognizer(tapGestureRecognizer)
        
        // Iterate over the image names and create UIImage objects
        for imageName in imageNames {
            if let image = UIImage(named: imageName) {
                images.append(image)
            }
        }
        if images.isEmpty {
            if let image = UIImage(named: genericImageName) {
                images.append(image)
            }
        }
        
        // Call the method to setup the carousel with the images
        setupCarousel()
    }
    
    @objc func somethingWasTapped(_ sth: AnyObject){
        shouldShowHeader.toggle()
        let appearance = UINavigationBarAppearance()
        if shouldShowHeader {
            appearance.configureWithTransparentBackground()
            
        } else {
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = UIColor(named: "AccentColor")
        }
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.compactAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance  = appearance
        
        UIView.animate(withDuration: 0.3) {
            self.headerHeightConstraint.constant = self.shouldShowHeader ? Constant.maxHeaderHeight : Constant.minHeaderHeight
            self.view.layoutIfNeeded()
        }
        
        self.backBarButton.image = shouldShowHeader ? UIImage(named: "BACK") : UIImage(named: "back_clear")
        self.moreBarButton.image = shouldShowHeader ? UIImage(named: "MORE") : UIImage(named: "more_clear")
        self.editBarButton.image = shouldShowHeader ? UIImage(named: "EDIT") : UIImage(named: "edit_clear")
    }
    
    private func handleFetchResult(_ result: Result<WineModel, Error>) {
        switch result {
        case .success(let wineModel):
            handleSuccess(wineModel)
        case .failure(let error):
            handleError(error)
        }
    }
    
    private func handleSuccess(_ wineModel: WineModel) {
        DispatchQueue.main.async {
            self.updateUI(with: wineModel)
        }
    }
    
    private func handleError(_ error: Error) {
        DispatchQueue.main.async {
            print("Error: \(error.localizedDescription)")
            // Show error message to the user or take appropriate action
            
            let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func updateUI(with wineModel: WineModel) {
        self.titleLabel.text = wineModel.code
        self.descriptionLabel.text = wineModel.description
        self.secondaryDescriptionLabel.text = wineModel.secondaryDescription
        self.secondaryDescriptionLabel.isHidden = wineModel.secondaryDescription == nil
        self.ownerNameLabel.text = wineModel.owner?.name
        self.unitNameLabel.text = wineModel.unit?.name
        self.configureBeverageProperties(with: wineModel)
    }
    
    private func configureBeverageProperties(with wineModel: WineModel) {
        
        if let beverageProperties = self.viewModel.wineModelItem?.beverageProperties {
            self.beverageColoredView.layer.cornerRadius = beverageColoredView.bounds.width/2
            self.beverageColoredView.clipsToBounds = true
            self.beverageColoredView.backgroundColor = UIColor(hex: "#\(beverageProperties.colour ?? "")")
            self.beverageDescriptionLabel.text = beverageProperties.description
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

extension WineItemViewController: UITableViewDataSource {
    
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
            return viewModel.wineModelItem?.components?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue:indexPath.section) {
        case .levels:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LevelTableViewCell", for: indexPath) as? LevelTableViewCell else {
                fatalError("Unable to dequeue LabelCell")
            }
            let quantity = viewModel.wineModelItem?.quantity
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
            cell.componentModel = self.viewModel.wineModelItem?.components?[indexPath.row]
            return cell
            
        case .none:
            fatalError("Invalid section")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 52
    }
}

extension WineItemViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
        
        let titleLabel = UILabel(frame: CGRect(x: 16, y: 0, width: 200, height: 40))
        titleLabel.text = section == .levels ? "Levels" : "Components"
        headerView.addSubview(titleLabel)
        
        if section == .levels {
            let editButtonWidth: CGFloat = 60
            let editButton = UIButton(type: .system)
            editButton.frame = CGRect(x: headerView.frame.width - editButtonWidth - 16, y: 0, width: editButtonWidth, height: 40)
            editButton.setTitle("Edit", for: .normal)
            editButton.setTitleColor(UIColor(named: "AccentColor"), for: .normal)
            editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
            headerView.addSubview(editButton)
        } else {
            let componentsCount = viewModel.wineModelItem?.components?.count ?? 0
            let countLabel = UILabel(frame: CGRect(x: titleLabel.frame.maxX + 6, y: 0, width: 50, height: 40))
            countLabel.text = "(\(componentsCount))"
            countLabel.textColor = UIColor(hex: "#999999")
            headerView.addSubview(countLabel)
        }
        
        return headerView
    }
    
    @objc private func editButtonTapped() {
        // Handle the edit button tap event for the "Levels" section
        print("Edit button tapped")
        let alertController = UIAlertController(title: "Edit", message: "this is something", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
        self.present(alertController, animated: true)
    }
}



