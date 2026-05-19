import Foundation
import os

public enum AppLogger {
    private static let subsystem = "com.lokei.lovebirds"
    public static let sync = Logger(subsystem: subsystem, category: "sync")
    public static let haptics = Logger(subsystem: subsystem, category: "haptics")
    public static let store = Logger(subsystem: subsystem, category: "store")
    public static let intent = Logger(subsystem: subsystem, category: "intent")
    public static let health = Logger(subsystem: subsystem, category: "health")
    public static let ui = Logger(subsystem: subsystem, category: "ui")
}
