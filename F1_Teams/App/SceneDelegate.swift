//
//  SceneDelegate.swift
//  F1_Teams
//
//  Created by Ivan Pavlov on 04.03.2026.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // MARK: Navigation Style
    private func applyNavigationStyle(to navigationController: UINavigationController) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.shadowColor = nil

        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        navigationController.navigationBar.compactAppearance = appearance
        navigationController.navigationBar.isTranslucent = true
    }

    // создание первого экрана приложения
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let tabBarController = UITabBarController()

        let teamsVC = F1TeamsViewController()
        let teamsNav = UINavigationController(rootViewController: teamsVC)
        teamsNav.navigationBar.prefersLargeTitles = false
        applyNavigationStyle(to: teamsNav)
        teamsNav.tabBarItem = UITabBarItem(
            title: "Команды",
            image: UIImage(systemName: "flag.checkered"),
            selectedImage: nil
        )

        let championshipVC = ChampionshipYearPickerViewController()
        let championshipNav = UINavigationController(rootViewController: championshipVC)
        championshipNav.navigationBar.prefersLargeTitles = false
        applyNavigationStyle(to: championshipNav)
        championshipNav.tabBarItem = UITabBarItem(
            title: "Пилоты",
            image: UIImage(systemName: "list.number"),
            selectedImage: nil
        )

        tabBarController.viewControllers = [teamsNav, championshipNav]

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        self.window = window
    }

    // работа с памяться при закрытии приложения
    func sceneDidDisconnect(_ scene: UIScene) {
    }

    // действия при активации приложения
    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    // дейсвтия при подготовке к закрытию (например, пауза в игре)
    func sceneWillResignActive(_ scene: UIScene) {
    }

    // дейсвтия при возобновление активности после фонового режима
    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    // действия при уходе в фоновый режим
    func sceneDidEnterBackground(_ scene: UIScene) {
    }


}
