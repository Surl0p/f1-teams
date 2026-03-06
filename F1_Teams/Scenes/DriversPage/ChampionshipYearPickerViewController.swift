//
//  ChampionshipYearPickerViewController.swift
//  F1_Teams
//
//  Created by Ivan Pavlov on 06.03.2026.
//

import UIKit

final class ChampionshipYearPickerViewController: UIViewController {

    // MARK: список доступных сезонов
    private let years: [Int] = Array(2010...2026).reversed()

    // MARK: скролл для кнопок годов
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: вертикальный стек с кнопками
    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        populateYearButtons()
    }

    // MARK: Methods
    private func configureView() {
        title = "Личный Зачёт"
        view.backgroundColor = .systemBackground

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    // MARK: создание кнопок годов
    private func populateYearButtons() {
        for year in years {
            var config = UIButton.Configuration.filled()
            config.title = String(year)
            config.baseBackgroundColor = .systemGray6
            config.baseForegroundColor = .label
            config.contentInsets = NSDirectionalEdgeInsets(
                top: 14,
                leading: 16,
                bottom: 14,
                trailing: 16
            )

            let button = UIButton(configuration: config)
            button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
            button.layer.cornerRadius = 12
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 52).isActive = true

            button.addAction(UIAction { [weak self] _ in
                self?.openChampionship(for: year)
            }, for: .touchUpInside)

            contentStack.addArrangedSubview(button)
        }
    }

    // MARK: переход к таблице выбранного сезона
    private func openChampionship(for year: Int) {
        let controller = DriversChampionshipViewController(season: year)
        navigationController?.pushViewController(controller, animated: true)
    }
}
