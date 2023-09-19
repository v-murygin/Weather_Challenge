//
//  ViewController.swift
//  Weather_Challenge
//
//  Created by Vladislav on 9/18/23.
//

import UIKit
import Combine

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.isHidden = true
        return stackView
    }()
    
    private lazy var stackViewButtons: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.spacing = 16
        return stackView
    }()
    
    private lazy var btnGeo: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Use my geo", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 12
        btn.backgroundColor = .blue
        btn.addTarget(self, action: #selector(didTapGeoButton), for: .touchUpInside)
        return btn
    }()
    private lazy var btnSearch: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Search", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .blue
        btn.layer.cornerRadius = 12
        btn.addTarget(self, action: #selector(didTapSearchButton), for: .touchUpInside)
        return btn
    }()
    private var lblInfo: UILabel = {
        let lbl = UILabel()
        lbl.text = "Add a city"
        lbl.textAlignment = .center
        lbl.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        return lbl
    }()
    
    private var cityLabel: UILabel = {
        let cityLabel = UILabel()
        cityLabel.text = "City name"
        cityLabel.textAlignment = .center
        cityLabel.font = UIFont.systemFont(ofSize: 50, weight: .bold)
        return cityLabel
    }()
    
    private var temperatureLabel: UILabel = {
        let temperatureLabel = UILabel()
        temperatureLabel.text = "Temp"
        temperatureLabel.textAlignment = .center
        temperatureLabel.font = UIFont.systemFont(ofSize: 100, weight: .medium)
        return temperatureLabel
    }()
    
    private var weatherImage: UIImageView = {
        let weatherImage = UIImageView()
        weatherImage.contentMode = .scaleAspectFit
        return weatherImage
    }()
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private var cancellables = Set<AnyCancellable>()
    private let viewModel = HomeViewModel()
    
    // MARK: -  Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        configure()
        setupConstraints()
        
        viewModel.startAppCheck()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            await viewModel.dataUpdate()
        }
    }
    
    // MARK: -  Screen Configuration
    func configure() {
        [lblInfo, stackViewButtons, stackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [btnGeo, btnSearch].forEach {
            stackViewButtons.addArrangedSubview($0)
        }
        
        [cityLabel, temperatureLabel, weatherImage].forEach {
            stackView.addArrangedSubview($0)
        }
        
        [activityIndicator, stackViewButtons, stackView, lblInfo].forEach {
            view.addSubview($0)
        }
        
        activityIndicator.color = .black
        activityIndicator.center = view.center
        view.backgroundColor = .white
    }
    
    func showAlert() {
        let alertController = UIAlertController(title: "Location not available", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo:safeArea.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: stackViewButtons.topAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            stackViewButtons.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            stackViewButtons.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            stackViewButtons.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -16),
            stackViewButtons.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            lblInfo.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            lblInfo.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor)
        ])

    }
    
    // MARK: -  Binding
    func setupBindings() {
        viewModel.$weatherData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.lblInfo.isHidden = (data != nil) ? true : false
                if let data = data, let temp = data.temp {
                    self?.activityIndicator.stopAnimating()
                    self?.activityIndicator.removeFromSuperview()
                    self?.cityLabel.text = data.name
                    self?.temperatureLabel.text = "\(Int(temp))°C"
                    self?.stackView.isHidden = false
                }
            }
            .store(in: &cancellables)
        
        viewModel.$weatherIcon
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.weatherImage.image = image
            }
            .store(in: &cancellables)
        
        
        viewModel.$locationUnavailable
            .sink { [weak self] status in
                if status == true {
                    self?.showAlert()
                    self?.activityIndicator.stopAnimating()
                    self?.activityIndicator.removeFromSuperview()
                }
            }
            .store(in: &cancellables)
        
        
    }
    
    // MARK: -  Functions
    
    @objc
    func didTapGeoButton () {
        viewModel.getLocation()
        activityIndicator.startAnimating()
        lblInfo.isHidden = true
    }

    @objc
    func didTapSearchButton () {
        let searchVC = SearchViewController()
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
}
