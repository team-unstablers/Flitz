//
//  File.swift
//  
//
//  Created by cheesekun on 5/27/24.
//

#if os(macOS) || os(iOS) || os(tvOS)

import os
import Foundation

extension OSLog: FZLogger {
    func fz_log(level: String, type: OSLogType, message: String) {
        if (!FZ_GLOBAL_LOGGER_LEVEL.shouldWriteLog(with: level)) {
            return;
        }

        os_log("[%@] %@", log: self, type: type, level, message)
    }

    public func debug(_ message: String) {
        fz_log(level: "DEBUG", type: .debug, message: message)
    }

    public func info(_ message: String) {
        fz_log(level: "INFO", type: .info, message: message)
    }

    public func warning(_ message: String) {
        fz_log(level: "WARNING", type: .default, message: message)
    }

    public func error(_ message: String) {
        fz_log(level: "ERROR", type: .error, message: message)
    }

    public func fatal(_ message: String) {
        fz_log(level: "FATAL", type: .fault, message: message)
    }
}

public func createFZOSLogger(_ tag: String, subsystem: String = "Flitz") -> FZLogger {
    return OSLog(subsystem: subsystem, category: tag)
}

#endif
