//
//  SearchViewController.swift
//  Weather_Challenge
//
//  Created by Vladislav on 9/18/23.
//

import UIKit
import SwiftUI
import Combine

class SearchViewController: UIViewController, UITableViewDelegate {
    
    // MARK: - Typealias
    typealias DataSource = UITableViewDiffableDataSource<Section, CitySearchCellModel>
    
    // MARK: - Properties
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Enter the city name or US Zip in the search field"
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Cities"
        return searchController
    }()
    
    private let searchDebounceDelay: TimeInterval = 0.5
    private var dataSource: DataSource!
    private var viewModel = SearchViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: -  Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    // MARK: -  Binding
    func setupBindings() {
        viewModel.$searchText
            .sink { [weak self] text in
                self?.infoLabel.isHidden = text.isEmpty  ? false : true
            }
            .store(in: &cancellables)
        
        viewModel.$cities
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateData()
            }
            .store(in: &cancellables)
        
        viewModel.$searchText
            .debounce(for: .seconds(searchDebounceDelay), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                guard !text.isEmpty else { return }
                Task {
                    await self?.viewModel.serchCity(searchText: text)
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: -  Screen Configuration
    private func configure(){
        title = "Search"
        view.backgroundColor = .white
        configureTableView()
        configureDataSource()
        configureSearchController()
        configureLabel()
        setupBindings()
    }
    
    private func configureLabel() {
        view.addSubview(infoLabel)
        NSLayoutConstraint.activate([
            infoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.backgroundColor = .white
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func configureDataSource() {
        dataSource = DataSource(tableView: tableView, cellProvider: { (tableView, indexPath, item) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = item.name + " (\(item.country))"
            return cell
        })
        updateData()
    }
    
    
    private func updateData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, CitySearchCellModel>()
        snapshot.appendSections([.city])
        snapshot.appendItems(viewModel.cities)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    // MARK: - Search bar configuration
    func configureSearchController() {
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
    }
}
extension SearchViewController: UITableViewDataSource {
    
    // MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.numberOfSections(in: tableView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.tableView(tableView, numberOfRowsInSection: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return dataSource.tableView(tableView, cellForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let city = dataSource.itemIdentifier(for: indexPath) else { return }
        
        let descriptionVC = DescriptionViewController(lat: city.lat, lon: city.lon) {
            self.navigationController?.popToRootViewController(animated: true)
        }
        
        let hostingController = UIHostingController(rootView: descriptionVC)
        self.navigationController?.pushViewController(hostingController, animated: true)
        
    }
}

extension SearchViewController: UISearchResultsUpdating {
    
    // MARK: - Search
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.searchText = searchController.searchBar.text ?? ""
        if searchController.searchBar.text == ""  {
            viewModel.cities = []
        }
    }
}
