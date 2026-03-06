//
//  NameInputViewController.swift
//  F1_Teams
//
//  Created by Ivan Pavlov on 04.03.2026.
//

import UIKit

final class NameInputViewController: UIViewController {

    // MARK: выбранная команда
    private let team: F1Team

    // MARK: крупная эмблема команды
    private lazy var logoImageView: UIImageView = {
        let image_view = UIImageView()
        image_view.contentMode = .scaleAspectFit
        image_view.clipsToBounds = true
        image_view.image = UIImage(named: team.logoName) ?? UIImage(systemName: "flag.checkered.2.crossed")
        image_view.translatesAutoresizingMaskIntoConstraints = false
        return image_view
    }()

    // MARK: фото болида
    private lazy var carImageView: UIImageView = {
        let image_view = UIImageView()
        image_view.contentMode = .scaleAspectFit
        image_view.clipsToBounds = true
        image_view.image = UIImage(named: team.carImageName) ?? UIImage(systemName: "car.fill")
        image_view.translatesAutoresizingMaskIntoConstraints = false
        return image_view
    }()

    // MARK: фиксированный список кнопок пилотов
    private lazy var driversButtonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: init
    init(team: F1Team) {
        self.team = team
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
        title = team.name

        let teamColor = UIColor(hex: team.brandColorHex) ?? .systemGray
        view.backgroundColor = teamColor.withAlphaComponent(0.90)

        view.addSubview(logoImageView)
        view.addSubview(driversButtonsStack)
        view.addSubview(carImageView)

        configureDriverButtons()

        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            logoImageView.heightAnchor.constraint(equalTo: logoImageView.widthAnchor, multiplier: 0.72),

            driversButtonsStack.topAnchor.constraint(greaterThanOrEqualTo: logoImageView.bottomAnchor, constant: 20),
            driversButtonsStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            driversButtonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            driversButtonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            carImageView.topAnchor.constraint(greaterThanOrEqualTo: driversButtonsStack.bottomAnchor, constant: 20),
            carImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            carImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.76),
            carImageView.heightAnchor.constraint(equalTo: carImageView.widthAnchor, multiplier: 0.45),
            carImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    // MARK: создание кнопок пилотов
    private func configureDriverButtons() {
        for (index, driver) in team.drivers.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(driver.name, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
            button.setTitleColor(.black, for: .normal)

            button.backgroundColor = UIColor.white.withAlphaComponent(0.88)
            button.layer.cornerRadius = 18
            button.clipsToBounds = true
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.black.withAlphaComponent(0.35).cgColor

            button.tag = index
            button.addAction(UIAction { [weak self] _ in
                self?.openDriver(by: index)
            }, for: .touchUpInside)

            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 56).isActive = true
            driversButtonsStack.addArrangedSubview(button)
        }
    }

    // MARK: переход на карточку пилота
    private func openDriver(by index: Int) {
        guard team.drivers.indices.contains(index) else { return }
        let selectedDriver = team.drivers[index]
        let controller = DriverDetailViewController(
            driver: selectedDriver,
            teamName: team.name,
            teamColorHex: team.brandColorHex
        )
        navigationController?.pushViewController(controller, animated: true)
    }
}
