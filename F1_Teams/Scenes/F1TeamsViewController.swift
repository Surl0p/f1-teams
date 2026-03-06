//
//  F1TeamsViewController.swift
//  F1_Teams
//
//  Created by Ivan Pavlov on 04.03.2026.
//

import UIKit

final class F1TeamsViewController: UIViewController {

    // MARK: команды Формулы-1
    private let teams = F1DataProvider.shared.loadTeams()

    // MARK: таблица команд
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.dataSource = self
        table.delegate = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "TeamCell")
        table.rowHeight = 72
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    // MARK: сообщение, если локальный JSON пока не добавлен в bundle
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Нет данных.\nДобавь f1_2026_teams.json в Resources/F1Data."
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    // MARK: Methods
    private func configureView() {
        title = "Команды F1 2026"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            emptyLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])

        let hasData = !teams.isEmpty
        tableView.isHidden = !hasData
        emptyLabel.isHidden = hasData
    }
}

// MARK:  UITableViewDataSource
extension F1TeamsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        teams.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TeamCell", for: indexPath)
        let team = teams[indexPath.row]

        var config = cell.defaultContentConfiguration()
        config.text = team.name
        config.secondaryText = "Состав: \(team.drivers.map(\.name).joined(separator: ", "))"
        config.textProperties.font = .systemFont(ofSize: 19, weight: .bold)
        config.secondaryTextProperties.font = .systemFont(ofSize: 13, weight: .semibold)

        let bgColor = UIColor(hex: team.brandColorHex) ?? .systemGray
        config.textProperties.color = .black
        config.secondaryTextProperties.color = .black

        cell.contentConfiguration = config
        cell.backgroundColor = bgColor
        cell.accessoryType = .disclosureIndicator

        return cell
    }
}

// MARK:  UITableViewDelegate
extension F1TeamsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let selectedTeam = teams[indexPath.row]
        let controller = NameInputViewController(team: selectedTeam)
        navigationController?.pushViewController(controller, animated: true)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.layer.cornerRadius = 16
        cell.contentView.layer.masksToBounds = true
    }
}
