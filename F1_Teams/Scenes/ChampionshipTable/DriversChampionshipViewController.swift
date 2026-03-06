//
//  DriversChampionshipViewController.swift
//  F1_Teams
//
//  Created by Ivan Pavlov on 06.03.2026.
//

import UIKit

final class DriversChampionshipViewController: UIViewController {

    // MARK: сервис загрузки таблицы чемпионата пилотов
    private let service = DriversChampionshipService()

    // MARK: данные таблицы
    private var rows: [DriversChampionshipEntry] = []

    // MARK: выбранный сезон
    private let season: Int

    // MARK: форматер очков (например, 395.5)
    private let pointsFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 0
        return formatter
    }()

    // MARK: таблица чемпионата пилотов
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.dataSource = self
        table.delegate = self
        table.register(ChampionshipCell.self, forCellReuseIdentifier: ChampionshipCell.reuseID)
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 104
        table.translatesAutoresizingMaskIntoConstraints = false
        table.isHidden = true
        return table
    }()

    // MARK: индикатор загрузки
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    // MARK: сообщение о пустом ответе или ошибке
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: init
    init(season: Int = Calendar.current.component(.year, from: Date())) {
        self.season = season
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        loadData()
    }

    // MARK: Methods
    private func configureView() {
        title = "Чемпионат пилотов \(season)"
        view.backgroundColor = .systemBackground

        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(messageLabel)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            messageLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }

    // MARK: загрузка таблицы за выбранный сезон
    private func loadData() {
        loadingIndicator.startAnimating()
        messageLabel.isHidden = true
        tableView.isHidden = true

        Task {
            do {
                let result = try await service.fetchDriversChampionship(year: season, limit: 100, offset: 0)
                await MainActor.run {
                    self.rows = result
                    self.loadingIndicator.stopAnimating()

                    if result.isEmpty {
                        self.messageLabel.text = "Нет данных чемпионата за \(self.season) год."
                        self.messageLabel.isHidden = false
                    } else {
                        self.tableView.isHidden = false
                        self.tableView.reloadData()
                    }
                }
            } catch {
                await MainActor.run {
                    self.loadingIndicator.stopAnimating()
                    self.messageLabel.text = "Не удалось загрузить данные.\n\(error.localizedDescription)"
                    self.messageLabel.isHidden = false
                }
            }
        }
    }
}

// MARK: UITableViewDataSource
extension DriversChampionshipViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }

    // MARK: строка таблицы пилота
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChampionshipCell.reuseID, for: indexPath)
        let row = rows[indexPath.row]
        let positionText = row.position.map(String.init) ?? "-"
        let pointsText = pointsFormatter.string(from: NSNumber(value: row.points)) ?? String(row.points)
        let titleText = "\(positionText). \(row.fullName)"
        let teamText = "Команда: \(row.teamName)"
        let pointsValueText = "Очки: \(pointsText)"
        let winsText = "Победы: \(row.wins)"

        guard let championshipCell = cell as? ChampionshipCell else {
            return cell
        }

        championshipCell.configure(
            title: titleText,
            team: teamText,
            points: pointsValueText,
            wins: winsText
        )
        return championshipCell
    }
}

// MARK: UITableViewDelegate
extension DriversChampionshipViewController: UITableViewDelegate { }

// MARK: ячейка таблицы чемпионата
private final class ChampionshipCell: UITableViewCell {
    static let reuseID = "ChampionshipCell"

    // MARK: место и имя пилота
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: название команды
    private let teamLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: очки (слева)
    private let pointsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: победы (справа)
    private let winsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: горизонтальный блок статистики
    private lazy var statsStack: UIStackView = {
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [pointsLabel, spacer, winsLabel])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: заполнение ячейки данными
    func configure(title: String, team: String, points: String, wins: String) {
        titleLabel.text = title
        teamLabel.text = team
        pointsLabel.text = points
        winsLabel.text = wins
    }

    // MARK: layout ячейки
    private func configureLayout() {
        selectionStyle = .none

        contentView.addSubview(titleLabel)
        contentView.addSubview(teamLabel)
        contentView.addSubview(statsStack)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            teamLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            teamLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            teamLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            statsStack.topAnchor.constraint(equalTo: teamLabel.bottomAnchor, constant: 6),
            statsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            statsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            statsStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

            pointsLabel.leadingAnchor.constraint(equalTo: statsStack.leadingAnchor),
            winsLabel.trailingAnchor.constraint(equalTo: statsStack.trailingAnchor)
        ])
    }
}
