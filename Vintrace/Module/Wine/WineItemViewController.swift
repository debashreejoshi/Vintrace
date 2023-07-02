//
//  ViewController.swift
//  Vintrace
//
//  Created by Debashree Joshi on 30/6/2023.
//

import UIKit

class WineItemViewController: UIViewController {
    
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
    var shouldShowHeader: Bool = true
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var backBarButton: UIBarButtonItem!
    
    @IBOutlet weak var moreBarButton: UIBarButtonItem!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    
    private let viewModel = WineItemViewModel()
    var components: [Component] = [Component]()
    
    private enum Constant {
        static let minHeaderHeight: CGFloat = 90
        static let maxHeaderHeight: CGFloat = 574
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindViewModel()
        viewModel.fetchData(completion: handleFetchResult)
        let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()

            navigationController?.navigationBar.standardAppearance = appearance
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(Self.somethingWasTapped(_:)))
        self.navigationController?.navigationBar.addGestureRecognizer(tapGestureRecognizer)
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
    
    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] wineModel in
            guard let wineModel = wineModel else {
                return
            }
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.components = wineModel.components
                self?.updateUI(with: wineModel)
            }
        }
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
            self.components = wineModel.components
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
        self.beverageDescriptionLabel.text = wineModel.beverageProperties.description
        self.ownerNameLabel.text = wineModel.owner.name
        self.unitNameLabel.text = wineModel.unit.name
    }
}

extension WineItemViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: String(section)) else {
            return 0
        }
        
        return viewModel.numberOfRowsInSection(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: String(indexPath.section)) {
        case .components:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ComponentTableViewCell", for: indexPath) as? ComponentTableViewCell else {
                fatalError("Unable to dequeue ComponentCell")
            }
            cell.componentModel = self.components[indexPath.row]
            return cell
            
        case .levels:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LevelTableViewCell", for: indexPath) as? LevelTableViewCell else {
                fatalError("Unable to dequeue LabelCell")
            }
            //   let label = viewModel.getLabelForRow(at: indexPath)
            //  cell.configure(with: label)
            return cell
            
        case .none:
            fatalError("Invalid section")
        }
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionType = Section.allSections[section]
        return sectionType.rawValue
    }
}

extension WineItemViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CustomHeaderView.reuseIdentifier) as? CustomHeaderView ?? CustomHeaderView(reuseIdentifier: CustomHeaderView.reuseIdentifier)
        
        let sectionType = Section.allSections[section]
        headerView.titleLabel.text = sectionType.rawValue
        
        if sectionType == .levels {
            headerView.button.setTitle("Edit", for: .normal)
        } else {
            headerView.button.setTitle("No title", for: .normal)
        }
        
        return headerView
    }
    
}


class CustomHeaderView: UITableViewHeaderFooterView {
    
    static let reuseIdentifier = "CustomHeaderView"
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        return label
    }()
    
    let button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.orange, for: .normal)
        button.addTarget(CustomHeaderView.self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
       
        contentView.backgroundColor = .lightGray
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(button)
        
        // Might need to add layout constraints for titleLabel and button
        
    }
    
    @objc private func buttonTapped() {
        // tap action here
    }
}
