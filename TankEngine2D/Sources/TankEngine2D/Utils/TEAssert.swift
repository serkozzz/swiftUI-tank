import Foundation

@MainActor
public enum TEAssert {
    
    // В unitTest-х задайте preconditionHandler чтобы перехватить precondition
    public static var preconditionHandler: ((Bool, String, StaticString, UInt) -> Void)?

    // Аналог precondition. В проде — вызывает Swift.precondition, в тестах — ваш handler.
    public static func precondition(_ condition: Bool,
                                    _ message: String = "",
                                    file: StaticString = #fileID,
                                    line: UInt = #line) {
        let ok = condition
        guard !ok else { return }
        if let handler = preconditionHandler {
            handler(ok, message, file, line)
        } else {
            Swift.precondition(ok, message, file: file, line: line)
        }
    }
}
