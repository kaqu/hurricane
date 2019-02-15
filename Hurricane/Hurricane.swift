import Foundation

public protocol ModuleDescription {
    typealias Module = ModuleInstance<Self>

    associatedtype View
    associatedtype State

    associatedtype Message
    typealias Action = (inout State) -> [Work]
    typealias Interpreter = (Message) -> Action

    static func interpreter() -> Interpreter

    associatedtype Context
    typealias Callback = (Message) -> Void

    associatedtype Work
    typealias Worker = (Work, @escaping Callback) -> Void

    static func worker(inContext context: Context) -> Worker

    static var initialization: [Message] { get }
    static func instantiate(with state: State, in context: Context, using executor: ModuleExecutor) -> ModuleInstance<Self>
}

extension ModuleDescription {
    public static var initialization: [Message] { return [] }
    public static func instantiate(with state: State, in context: Context, using executor: ModuleExecutor = DispatchQueue(label: "\(Self.self) Executor")) -> ModuleInstance<Self> {
        return .init(state: state, interpreter: Self.interpreter(), worker: Self.worker(inContext: context), executor: executor)
    }
}

public final class ModuleInstance<Description: ModuleDescription> {
    public typealias State = Description.State

    public typealias Message = Description.Message
    public typealias Action = Description.Action
    public typealias Interpreter = Description.Interpreter

    public typealias Context = Description.Context
    public typealias Callback = Description.Callback
    public typealias Work = Description.Work
    public typealias Worker = Description.Worker

    private var state: State

    private let interpreter: Interpreter
    private let worker: Worker
    private let executor: ModuleExecutor

    public init(state: State, interpreter: @escaping Interpreter, worker: @escaping Worker, executor: ModuleExecutor) {
        self.state = state
        self.interpreter = interpreter
        self.worker = worker
        self.executor = executor
        Description.initialization.forEach(recieve)
    }

    public func recieve(_ message: Message) {
        enqueue(interpreter(message))
    }

    public func weakReciever() -> (Message) -> Void {
        return { [weak self] message in
            self?.recieve(message)
        }
    }

    private let queueLock: NSRecursiveLock = .init()
    private var actionQueue: [Action] = []
    private func enqueue(_ action: @escaping Action) {
        queueLock.lock()
        defer { queueLock.unlock() }
        actionQueue.append(action)
        executeIfNeeded()
    }

    private let executionLock: NSRecursiveLock = .init()
    private var isExecuting: Bool = false
    private func executeIfNeeded() {
        executionLock.lock()
        guard !isExecuting else { return executionLock.unlock() }
        isExecuting = true
        executionLock.unlock()
        executor.execute {
            defer {
                self.executionLock.lock()
                self.isExecuting = false
                self.executionLock.unlock()
            }
            defer { self.queueLock.unlock() }
            while ({ () -> Bool in
                self.queueLock.lock()
                return !self.actionQueue.isEmpty
            }()) {
                let action = self.actionQueue.removeFirst()
                self.queueLock.unlock()
                for task in action(&self.state) {
                    self.worker(task, { [weak self] message in self?.recieve(message) })
                }
            }
        }
    }
}

public protocol ModuleExecutor {
    func execute(_ closure: @escaping () -> Void)
}

public struct InstantExecutor: ModuleExecutor {
    public func execute(_ closure: @escaping () -> Void) {
        closure()
    }

    public init() {}
}

extension DispatchQueue: ModuleExecutor {
    public func execute(_ closure: @escaping () -> Void) {
        async(execute: closure)
    }
}

extension OperationQueue: ModuleExecutor {
    public func execute(_ closure: @escaping () -> Void) {
        if OperationQueue.current == self {
            closure()
        } else {
            addOperation(closure)
        }
    }
}
