import Foundation
import Combine
import SwiftUI

extension UserDefaults {
    @objc dynamic var managedConfig: [String:Any]? {
        return dictionary(forKey: "com.apple.configuration.managed")
    }
}
let decoder = PropertyListDecoder()
public protocol AppSettingsConfig : Codable, Equatable {
    func combine(config:Self?) -> Self
    var keyValueRepresentation: [String : String] { get }
}
extension AppSettingsConfig {
    static func decoded(from data:Data) throws -> Self {
        return try decoder.decode(Self.self, from: data)
    }
    static func decoded(from dictionary:[String:Any]) throws -> Self {
        let data = try JSONSerialization.data(withJSONObject: dictionary)
        let decoder = JSONDecoder()
        return try decoder.decode(Self.self, from: data)
    }
    static func read(name:String, bundle:Bundle = Bundle.main) -> Self? {
        guard let plistPath: String = bundle.path(forResource: name, ofType: "plist") else {
            return nil
        }
        guard let data = FileManager.default.contents(atPath: plistPath) else {
            return nil
        }
        do {
            return try decoded(from: data)
        } catch {
            debugPrint(error)
        }
        return nil
    }
    public var keyValueRepresentation: [String : String] {
        func value(from any:Any) -> String? {
            if let v = any as? String {
                return v
            } else if let v = any as? Int {
                return "\(v)"
            } else if let v = any as? Double {
                return "\(v)"
            } else if let v = any as? Bool {
                return "\(v)"
            }
            return String(describing: any)
        }
        var dict = [String : String]()
        for child in Mirror(reflecting: self).children {
            guard let label = child.label else {
                continue
            }
            if let value = value(from: child.value) {
                dict[label] = value
            }
        }
        return dict
    }
}

public class AppSettings<Config: AppSettingsConfig>: ObservableObject {
    @Published public var config:Config?
    private let fileName:String?
    private let mixWithDefault:Bool
    private let bundle:Bundle
    private var appConfigPublisher:AnyCancellable?
    public init(defaultsFromFile name:String? = nil, bundle:Bundle = Bundle.main, managedConfigEnabled:Bool = true, mixWithDefault:Bool = true) {
        self.bundle = bundle
        self.fileName = name
        self.mixWithDefault = true
        if managedConfigEnabled {
            if let c = managedConfig {
                self.set(config:resolve(config: c))
            } else {
                self.set(config:defaultConfig)
            }
            appConfigPublisher = UserDefaults.standard.publisher(for: \.managedConfig).tryMap { dict -> Config? in
                guard let dict = dict else {
                    return nil
                }
                return try Config.decoded(from: dict)
            }.replaceError(with: nil).sink(receiveValue: { [weak self] config in
                if let config = config {
                    self?.set(config: self?.resolve(config: config))
                } else {
                    self?.set(config: self?.defaultConfig)
                }
            })
        } else {
            self.set(config:defaultConfig)
        }
    }
    func resolve(config:Config) -> Config {
        if mixWithDefault == false {
            return config
        }
        return config.combine(config: defaultConfig)
    }
    func set(config:Config?) {
        if config == self.config {
            return
        }
        self.config = config
    }
    public var defaultConfig:Config? {
        guard let fileName = fileName else {
            return nil
        }
        return Config.read(name: fileName, bundle: bundle)
    }
    public var managedConfig:Config? {
        guard let dict = UserDefaults.standard.managedConfig, let c = try? Config.decoded(from: dict) else {
            return nil
        }
        return c
    }
}
