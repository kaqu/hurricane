//
//  RootTests.swift
//  HurricaneTests
//
//  Created by Kacper Kaliński on 15/02/2019.
//  Copyright © 2019 Miquido. All rights reserved.
//

import Hurricane
import UIKit
import XCTest

class RootTests: XCTestCase {
    func testInterpreter() {
        var state: Root.State = .init()
        Root
            .interpreter(.prepareDashboard)(&state)
            .forEach { work in
                switch work {
                    case .buildDashboard: break
                    case .show: XCTFail()
                }
            }

        // TODO: it acctually cannot be tested...
        // work = Root.interpreter(.setupDashboard(Dashboard.Module, view: Dashboard.View))
    }

    func testWorker() {
        // TODO: remove UI dependency, it acctually cannot be tested...
        let window: UIWindow = .init()
        let worker = Root.worker(inContext: Root.Context(mainWindow: window))

        worker(Root.Work.buildDashboard(Dashboard.State()), { message in
            switch message {
                case .prepareDashboard: XCTFail()
                case .setupDashboard: break
            }
        })

        // TODO: remove UI dependency, it acctually cannot be tested...
        let viewController: UIViewController = .init()
        worker(Root.Work.show(rootViewController: viewController), { message in
            switch message {
                case .prepareDashboard: XCTFail()
                case .setupDashboard: XCTFail()
            }
        })
    }
}
