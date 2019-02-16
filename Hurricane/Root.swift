import UIKit

public enum Root: ModuleDescription {
    public typealias View = UIWindow

    public struct State {
        fileprivate var dashboardModule: Dashboard.Module?
        public init() {}
    }

    public enum Message {
        case prepareDashboard
        case setupDashboard(Dashboard.Module, view: Dashboard.View)
    }

    public enum Work {
        case buildDashboard(Dashboard.State)
        case show(rootViewController: UIViewController)
    }

    public struct Context {
        fileprivate let mainWindow: UIWindow
        public init(mainWindow: UIWindow = .init(frame: UIScreen.main.bounds)) {
            self.mainWindow = mainWindow
        }
    }
    public static var interpreter: Interpreter {
        return { message in
            switch message {
                case .prepareDashboard:
                    return { _ in
                        [.buildDashboard(Dashboard.State())]
                    }
                case let .setupDashboard(module, view):
                    return { state in
                        state.dashboardModule = module
                        return [.show(rootViewController: UINavigationController(rootViewController: view))]
                    }
            }
        }
    }

    public static func worker(inContext context: Context) -> Worker {
        return { task, callback in
            switch task {
                case let .buildDashboard(state):
                    let dashboardView: Dashboard.View = .init()
                    let dashboardModule: Dashboard.Module
                        = Dashboard.instantiate(with: state,
                                                in: Dashboard.Context(view: dashboardView))
                    dashboardView.interactor = dashboardModule.weakReciever()
                    callback(.setupDashboard(dashboardModule, view: dashboardView))
                case let .show(viewController):
                    context.mainWindow.rootViewController = viewController
                    context.mainWindow.makeKeyAndVisible()
            }
        }
    }
}
