//
// Created by Gyuhwan Park on 2022/05/23.
//

import Foundation

public enum FZGlobalLoggerLevel {
    case verbose
    case normal
    case quiet

    func shouldWriteLog(with level: String) -> Bool {
        if (self == .verbose) {
            return true
        }

        if (self == .normal) {
            return level != "DEBUG"
        }

        return false
    }
}

public protocol FZLogger {
    func debug(_ message: String)
    func info(_ message: String)
    func warning(_ message: String)
    func error(_ message: String)
    func fatal(_ message: String)
}

var FZ_GLOBAL_LOGGER_LEVEL: FZGlobalLoggerLevel = .normal

public func setGlobalLoggerLevel(_ level: FZGlobalLoggerLevel) {
    FZ_GLOBAL_LOGGER_LEVEL = level
}

open class FZConsoleLogger: FZLogger {
    private let subsystem: String
    private let tag: String

    private var now: String {
        get {
#if os(macOS) || os(iOS) || os(tvOS)
            Date.now.formatted()
#else
            "\(Date.now)"
#endif
        }
    }

    init(tag: String, subsystem: String) {
        self.subsystem = subsystem
        self.tag = tag
    }

    public func write(level: String, tag: String, message: String) {
        if (!FZ_GLOBAL_LOGGER_LEVEL.shouldWriteLog(with: level)) {
            return;
        }

        fputs("[\(now)][\(tag):\(level)] \(message)\n", stderr)
    }

    public func debug(_ message: String) {
        write(level: "DEBUG", tag: tag, message: message)
    }

    public func info(_ message: String) {
        write(level: "INFO", tag: tag, message: message)
    }

    public func warning(_ message: String) {
        write(level: "WARNING", tag: tag, message: message)
    }

    public func error(_ message: String) {
        write(level: "ERROR", tag: tag, message: message)
    }

    public func fatal(_ message: String) {
        write(level: "FATAL", tag: tag, message: message)
    }
}

class FZMuxedLogger: FZLogger {

    private let subsystem: String
    private let tag: String

    private var impls: Array<FZLogger> = []

    init(tag: String, subsystem: String) {
        self.subsystem = subsystem
        self.tag = tag

#if os(macOS) || os(iOS) || os(tvOS)
        impls.append(createFZOSLogger(tag, subsystem: subsystem))
        // impls.append(createNOCConsoleLogger(tag, subsystem: subsystem))
#else
        impls.append(createFZConsoleLogger(tag, subsystem: subsystem))
#endif
        
    }

    public func debug(_ message: String) {
        impls.forEach { $0.debug(message) }
    }

    public func info(_ message: String) {
        impls.forEach { $0.info(message) }
    }

    public func warning(_ message: String) {
        impls.forEach { $0.warning(message) }
    }

    public func error(_ message: String) {
        impls.forEach { $0.error(message) }
    }

    public func fatal(_ message: String) {
        impls.forEach { $0.fatal(message) }
    }
}

public func createFZConsoleLogger(_ tag: String, subsystem: String = "Flitz") -> FZConsoleLogger {
    return FZConsoleLogger(tag: tag, subsystem: subsystem)
}

public func createFZMuxedLogger(_ tag: String, subsystem: String = "Flitz") -> FZLogger {
    return FZMuxedLogger(tag: tag, subsystem: subsystem)
}
