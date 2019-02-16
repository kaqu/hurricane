//
//  DetailTests.swift
//  HurricaneTests
//
//  Created by Kacper Kaliński on 15/02/2019.
//  Copyright © 2019 Miquido. All rights reserved.
//

import Hurricane
import UIKit
import XCTest

class DetailTests: XCTestCase {
    func testInterpreter() {
        var state: Detail.State = .init()
        Detail
            .interpreter(.back)(&state)
            .forEach { work in
                switch work {
                    case .perform(.back): break
                    case .perform: XCTFail()
                    case .present: XCTFail()
                }
            }

        Detail
            .interpreter(.bounce)(&state)
            .forEach { work in
                switch work {
                    case .perform(.bounce): break
                    case .present: XCTFail()
                    case .perform: XCTFail()
                }
            }
    }

    func testWorker() {
        // TODO: remove UI dependency, it acctually cannot be tested...
        let view: Detail.View = .init()
        var worker = Detail.worker(inContext: Detail.Context(view: view, parentInteractor: { message in
            switch message {
            case .prepareDetail: XCTFail()
            case .backFromDetail: break
            case .setupDetail: XCTFail()
            }
        }))

        worker(Detail.Work.perform(.back)) { message in
            switch message {
                case .bounce: XCTFail()
                case .back: XCTFail()
            }
        }
        
        worker = Detail.worker(inContext: Detail.Context(view: view, parentInteractor: { message in
            switch message {
            case .prepareDetail: break
            case .backFromDetail: break
            case .setupDetail: XCTFail()
            }
        }))

        worker(Detail.Work.perform(.bounce)) { message in
            switch message {
                case .bounce: XCTFail()
                case .back: XCTFail()
            }
        }
    }
}
