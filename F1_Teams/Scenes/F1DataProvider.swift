//
//  F1DataProvider.swift
//  F1_Teams
//
//  Created by Ivan Pavlov on 04.03.2026.
//

import UIKit

// MARK: модель пилота
struct F1Driver: Decodable {
    let name: String
    let imageName: String
    let quote: String
}

// MARK: модель команды
struct F1Team: Decodable {
    let name: String
    let brandColorHex: String
    let logoName: String
    let carImageName: String
    let drivers: [F1Driver]
}

// MARK: корневая модель JSON
private struct F1TeamsResponse: Decodable {
    let teams: [F1Team]
}

// MARK: провайдер данных из локального файла
final class F1DataProvider {

    static let shared = F1DataProvider()

    private init() { }

    func loadTeams() -> [F1Team] {
        guard let url = Bundle.main.url(forResource: "f1_2026_teams", withExtension: "json") else {
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let response = try JSONDecoder().decode(F1TeamsResponse.self, from: data)
            return response.teams
        } catch {
            print("Не удалось прочитать f1_2026_teams.json: \(error)")
            return []
        }
    }
}

// MARK: helpers для цвета
extension UIColor {

    convenience init?(hex: String) {
        var text = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if text.hasPrefix("#") {
            text.removeFirst()
        }

        guard text.count == 6, let value = Int(text, radix: 16) else {
            return nil
        }

        let red = CGFloat((value >> 16) & 0xFF) / 255.0
        let green = CGFloat((value >> 8) & 0xFF) / 255.0
        let blue = CGFloat(value & 0xFF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
