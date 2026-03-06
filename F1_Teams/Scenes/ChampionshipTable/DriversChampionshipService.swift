//
//  DriversChampionshipService.swift
//  F1_Teams
//
//  Created by Ivan Pavlov on 06.03.2026.
//

import Foundation

// MARK: строка таблицы чемпионата пилотов
struct DriversChampionshipEntry: Decodable {
    let position: Int?
    let points: Double
    let wins: Int
    let fullName: String
    let teamName: String

    // MARK: ключи JSON
    private enum CodingKeys: String, CodingKey {
        case position
        case points
        case wins
        case driver
        case team
        case driverName = "driver_name"
        case teamName = "team_name"
    }

    // MARK: декодирование данных чемпионата
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        position = Self.decodeInt(container, key: .position)
        points = Self.decodeDouble(container, key: .points) ?? 0
        wins = Self.decodeInt(container, key: .wins) ?? 0

        let fallbackDriverName = (try? container.decode(String.self, forKey: .driverName))?.trimmingCharacters(in: .whitespacesAndNewlines)
        if
            let driver = try? container.decode(ChampionshipDriver.self, forKey: .driver),
            let decodedName = driver.displayName,
            !decodedName.isEmpty
        {
            fullName = decodedName
        } else {
            fullName = (fallbackDriverName?.isEmpty == false) ? fallbackDriverName ?? "Unknown Driver" : "Unknown Driver"
        }

        let fallbackTeamName = (try? container.decode(String.self, forKey: .teamName))?.trimmingCharacters(in: .whitespacesAndNewlines)
        if
            let team = try? container.decode(ChampionshipTeam.self, forKey: .team),
            let decodedName = team.displayName,
            !decodedName.isEmpty
        {
            teamName = decodedName
        } else {
            teamName = (fallbackTeamName?.isEmpty == false) ? fallbackTeamName ?? "Unknown Team" : "Unknown Team"
        }
    }

    // MARK: парсинг целого числа
    private static func decodeInt(_ container: KeyedDecodingContainer<CodingKeys>, key: CodingKeys) -> Int? {
        if let intValue = try? container.decode(Int.self, forKey: key) {
            return intValue
        }

        if let doubleValue = try? container.decode(Double.self, forKey: key) {
            return Int(doubleValue)
        }

        if let textValue = try? container.decode(String.self, forKey: key) {
            return Int(textValue)
        }

        return nil
    }

    // MARK: парсинг дробного числа
    private static func decodeDouble(_ container: KeyedDecodingContainer<CodingKeys>, key: CodingKeys) -> Double? {
        if let doubleValue = try? container.decode(Double.self, forKey: key) {
            return doubleValue
        }

        if let intValue = try? container.decode(Int.self, forKey: key) {
            return Double(intValue)
        }

        if let textValue = try? container.decode(String.self, forKey: key) {
            return Double(textValue)
        }

        return nil
    }
}

// MARK: вложенный объект driver
private struct ChampionshipDriver: Decodable {
    let name: String?
    let surname: String?
    let firstName: String?
    let lastName: String?
    let givenName: String?
    let familyName: String?

    // MARK: ключи JSON
    private enum CodingKeys: String, CodingKey {
        case name
        case surname
        case firstName = "first_name"
        case lastName = "last_name"
        case givenName = "given_name"
        case familyName = "family_name"
    }

    // MARK: формирование полного имени пилота
    var displayName: String? {
        if let name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            let cleanSurname = surname?.trimmingCharacters(in: .whitespacesAndNewlines)
            if let cleanSurname, !cleanSurname.isEmpty {
                return "\(cleanName) \(cleanSurname)"
            }
            return cleanName
        }

        let first = firstName ?? givenName ?? name
        let last = lastName ?? familyName ?? surname
        let joined = [first, last]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        return joined.isEmpty ? nil : joined
    }
}

// MARK: вложенный объект team
private struct ChampionshipTeam: Decodable {
    let name: String?
    let teamNameCamelCase: String?
    let teamName: String?
    let constructorNameCamelCase: String?
    let constructorName: String?

    // MARK: ключи JSON
    private enum CodingKeys: String, CodingKey {
        case name
        case teamNameCamelCase = "teamName"
        case teamName = "team_name"
        case constructorNameCamelCase = "constructorName"
        case constructorName = "constructor_name"
    }

    // MARK: получение валидного названия команды
    var displayName: String? {
        for value in [name, teamNameCamelCase, teamName, constructorNameCamelCase, constructorName] {
            if let value, !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return value
            }
        }
        return nil
    }
}

// MARK: корневая модель ответа API
private struct DriversChampionshipResponse: Decodable {
    let driversChampionship: [DriversChampionshipEntry]

    private enum CodingKeys: String, CodingKey {
        case driversChampionship = "drivers_championship"
    }
}

enum DriversChampionshipError: LocalizedError {
    case invalidURL
    case badStatusCode(Int)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Некорректный URL запроса."
        case .badStatusCode(let code):
            return "Сервер вернул ошибку: \(code)."
        case .invalidResponse:
            return "Не удалось декодировать ответ сервера."
        }
    }
}

final class DriversChampionshipService {
    // MARK: базовый URL API
    private let baseURL = "https://f1api.dev/api"

    // MARK: запрос таблицы чемпионата пилотов
    func fetchDriversChampionship(
        year: Int,
        limit: Int = 100,
        offset: Int = 0
    ) async throws -> [DriversChampionshipEntry] {
        guard var components = URLComponents(string: "\(baseURL)/\(year)/drivers-championship") else {
            throw DriversChampionshipError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "offset", value: String(offset))
        ]

        guard let url = components.url else {
            throw DriversChampionshipError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw DriversChampionshipError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw DriversChampionshipError.badStatusCode(httpResponse.statusCode)
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(DriversChampionshipResponse.self, from: data).driversChampionship
        } catch {
            throw DriversChampionshipError.invalidResponse
        }
    }
}
