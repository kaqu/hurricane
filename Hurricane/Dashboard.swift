import UIKit

public enum Dashboard: ModuleDescription {
    public final class View: UIViewController {
        internal var interactor: ((Message) -> Void)?

        public override func loadView() {
            super.loadView()
            view.backgroundColor = .white

            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle("Show detail", for: .normal)
            button.setTitleColor(.blue, for: .normal)
            button.addTarget(self, action: #selector(buttonTap), for: .touchUpInside)
            view.addSubview(button)
            NSLayoutConstraint.activate([
                button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            ])
        }

        @objc private func buttonTap() {
            interactor?(.prepareDetail)
        }
    }

    public struct State {
        fileprivate var detailModule: Detail.Module?
        public init() {}
    }

    public enum Message {
        case prepareDetail
        case setupDetail(Detail.Module, view: Detail.View)
        case backFromDetail
    }

    public enum Work {
        case present(Presentation)
        public enum Presentation {
            case show(viewController: UIViewController)
            case backToSelf
        }

        case perform(Task)
        public enum Task {
            case buildDetail(Detail.State)
        }
    }

    public struct Context {
        fileprivate let view: View
        public init(view: View) {
            self.view = view
        }
    }

    public static var initialization: [Message] = []

    public static func interpreter() -> Interpreter {
        return { message in
            switch message {
                case .prepareDetail:
                    return { _ in
                        [.perform(.buildDetail(Detail.State()))]
                    }
                case let .setupDetail(module, view):
                    return { state in
                        state.detailModule = module
                        return [.present(.show(viewController: view))]
                    }
                case .backFromDetail:
                    return { state in
                        state.detailModule = nil
                        return [.present(.backToSelf)]
                    }
            }
        }
    }

    public static func worker(inContext context: Context) -> Worker {
        return { task, callback in
            switch task {
                case let .present(presentation):
                    DispatchQueue.main.async {
                        switch presentation {
                            case let .show(viewController):
                                context.view.show(viewController, sender: nil)
                            case .backToSelf:
                                if context.view.presentedViewController != nil {
                                    context.view.dismiss(animated: true, completion: nil)
                                } else {
                                    context.view.navigationController?.popToViewController(context.view, animated: true)
                                }
                        }
                    }
                case let .perform(task):
                    switch task {
                        case let .buildDetail(state):
                            let detailView: Detail.View = .init()
                            let detailModule: Detail.Module
                                = Detail.instantiate(with: state,
                                                     in: Detail.Context(view: detailView,
                                                                        parentInteractor: callback))
                            detailView.interactor = detailModule.weakReciever()
                            callback(.setupDetail(detailModule, view: detailView))
                    }
            }
        }
    }
}
