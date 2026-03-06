//
//  DriverDetailViewController.swift
//  F1_Teams
//
//  Created by Ivan Pavlov on 04.03.2026.
//

import UIKit

final class DriverDetailViewController: UIViewController {

    // MARK: данные
    private let driver: F1Driver
    private let teamName: String
    private let teamColorHex: String

    // MARK: имя пилота
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = driver.name
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: фото пилота
    private lazy var imageView: UIImageView = {
        let image_view = UIImageView()
        image_view.contentMode = .scaleAspectFill
        image_view.clipsToBounds = true
        image_view.layer.cornerRadius = 16
        image_view.image = UIImage(named: driver.imageName) ?? UIImage(systemName: "person.fill")
        image_view.translatesAutoresizingMaskIntoConstraints = false
        return image_view
    }()

    // MARK: название команды
    private lazy var teamLabel: UILabel = {
        let label = UILabel()
        label.text = teamName
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: известная фраза
    private lazy var quoteLabel: UILabel = {
        let label = UILabel()
        label.text = "\"\(driver.quote)\""
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: регулирование всего по центру
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [nameLabel, imageView, teamLabel, quoteLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: init
    init(driver: F1Driver, teamName: String, teamColorHex: String) {
        self.driver = driver
        self.teamName = teamName
        self.teamColorHex = teamColorHex
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    // MARK: Methods
    private func configureView() {
        title = "Пилот"
        let teamColor = UIColor(hex: teamColorHex) ?? .systemGray
        view.backgroundColor = teamColor.withAlphaComponent(0.90)
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.78),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
        ])
    }
}
