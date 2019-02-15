import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let root: Root.Module = Root.instantiate(with: Root.State(), in: Root.Context(), using: InstantExecutor())

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        root.recieve(.prepareDashboard)
        return true
    }
}
