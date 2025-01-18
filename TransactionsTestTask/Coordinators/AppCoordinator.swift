//
//  AppCoordinator.swift
//  TransactionsTestTask
//
//

import UIKit
import Combine

final class AppCoordinator: Coordinator<Void> {
    unowned let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    override func start(animated: Bool) -> AnyPublisher<Void, Never> {
        let navigationController = UINavigationController()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        let homeCoordinator = HomeCoordinator(navigationController: navigationController)
        return coordinate(to: homeCoordinator, animated: false)
    }
}
