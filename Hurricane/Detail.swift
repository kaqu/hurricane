import UIKit

public enum Detail: ModuleDescription {
    public final class View: UIViewController {
        internal var interactor: ((Message) -> Void)?

        public override func loadView() {
            super.loadView()
            view.backgroundColor = .white

            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle("Bounce", for: .normal)
            button.setTitleColor(.blue, for: .normal)
            button.addTarget(self, action: #selector(buttonTap), for: .touchUpInside)
            view.addSubview(button)
            NSLayoutConstraint.activate([
                button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            ])
        }

        @objc private func buttonTap() {
            interactor?(.bounce)
        }

        public override func willMove(toParent parent: UIViewController?) {
            super.willMove(toParent: parent)
            guard parent == nil else { return }
            interactor?(.back)
        }
    }

    public struct State {
        public init() {}
    }

    public enum Message {
        case bounce
        case back
    }

    public enum Work {
        case present(Presentation)
        public enum Presentation {}

        case perform(Task)
        public enum Task {
            case bounce
            case back
        }
    }

    public struct Context {
        fileprivate let view: View
        fileprivate let parentInteractor: (Dashboard.Message) -> Void
        public init(view: View, parentInteractor: @escaping (Dashboard.Message) -> Void) {
            self.view = view
            self.parentInteractor = parentInteractor
        }
    }

    public static var initialization: [Message] = []

    public static func interpreter() -> Interpreter {
        return { message in
            switch message {
                case .bounce:
                    return { _ in
                        [.perform(.bounce)]
                    }
                case .back:
                    return { _ in
                        [.perform(.back)]
                    }
            }
        }
    }

    public static func worker(inContext context: Context) -> Worker {
        return { task, _ in
            switch task {
                case let .present(presentation):
                    DispatchQueue.main.async {
                        switch presentation {}
                    }
                case let .perform(task):
                    switch task {
                        case .bounce:
                            context.parentInteractor(.backFromDetail)
                            context.parentInteractor(.prepareDetail)
                        case .back:
                            context.parentInteractor(.backFromDetail)
                    }
            }
        }
    }
}
