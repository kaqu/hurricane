//
//  DashboardTests.swift
//  HurricaneTests
//
//  Created by Kacper Kaliński on 15/02/2019.
//  Copyright © 2019 Miquido. All rights reserved.
//

import Hurricane
import UIKit
import XCTest

class DashboardTests: XCTestCase {
    func testInterpreter() {
        var state: Dashboard.State = .init()
        Dashboard
            .interpreter(.prepareDetail)(&state)
            .forEach { work in
                switch work {
                    case .perform(.buildDetail): break
                    case .present: XCTFail()
                }
            }

        Dashboard
            .interpreter(.backFromDetail)(&state)
            .forEach { work in
                switch work {
                    case .present(.backToSelf): break
                    case .present: XCTFail()
                    case .perform: XCTFail()
                }
            }

        // TODO: it acctually cannot be tested...
        // Dashboard.interpreter(.setupDetail(Detail.Module, view: Detail.View))(&state)
    }

    func testWorker() {
        // TODO: remove UI dependency, it acctually cannot be tested...
        let view: Dashboard.View = .init()
        let worker = Dashboard.worker(inContext: Dashboard.Context(view: view))

        worker(Dashboard.Work.present(.backToSelf)) { message in
            switch message {
                case .prepareDetail: XCTFail()
                case .setupDetail: XCTFail()
                case .backFromDetail: XCTFail()
            }
        }

        // TODO: remove UI dependency, it acctually cannot be tested...
        let viewController: UIViewController = .init()
        worker(Dashboard.Work.present(.show(viewController: viewController))) { message in
            switch message {
                case .prepareDetail: XCTFail()
                case .setupDetail: XCTFail()
                case .backFromDetail: XCTFail()
            }
        }

        worker(Dashboard.Work.perform(.buildDetail(Detail.State()))) { message in
            switch message {
                case .setupDetail: break
                case .prepareDetail: XCTFail()
                case .backFromDetail: XCTFail()
            }
        }
    }
}
