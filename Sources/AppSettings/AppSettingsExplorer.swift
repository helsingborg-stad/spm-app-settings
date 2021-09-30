//
//  SwiftUIView.swift
//  
//
//  Created by Tomas Green on 2021-09-17.
//

import SwiftUI
extension AppSettings {
    var defaultConfigContianer:AppSettingsExplorer.ConfigContainer? {
        guard let c = self.defaultConfig else {
            return nil
        }
        return AppSettingsExplorer.ConfigContainer(title: "Standard", config: c)
    }
    var managedConfigContianer:AppSettingsExplorer.ConfigContainer? {
        guard let c = self.managedConfig else {
            return nil
        }
        return AppSettingsExplorer.ConfigContainer(title: "Managerad", config: c)
    }
    var currentConfigContinaer:AppSettingsExplorer.ConfigContainer? {
        guard let c = self.config else {
            return nil
        }
        return AppSettingsExplorer.ConfigContainer(title: "Gällande", config: c)
    }
    var containers:[AppSettingsExplorer.ConfigContainer] {
        var arr = [AppSettingsExplorer.ConfigContainer]()
        if let c = currentConfigContinaer {
            arr.append(c)
        }
        if let c = managedConfigContianer {
            arr.append(c)
        }
        if let c = defaultConfigContianer {
            arr.append(c)
        }
        return arr
    }
    public struct AppSettingsExplorer: View {
        public struct ConfigContainer {
            public let title:String
            public let config:Config
            public init(title:String, config:Config) {
                self.title = title
                self.config = config
            }
        }
        var configs:[ConfigContainer]
        var overlay:some View {
            Group {
                if configs.count != 0 {
                    EmptyView()
                } else {
                    Text("Saknar konfiguration")
                }
            }
        }
        public var body: some View {
            Form {
                ForEach(0..<configs.count) { i in
                    let container = configs[i]
                    Section(header:Text(container.title)) {
                        ForEach(container.config.keyValueRepresentation.sorted(by: >), id: \.key) { key, value in
                            VStack(alignment:.leading) {
                                Text(key).font(.headline)
                                Text(value).font(.body)
                            }
                        }
                    }
                }
            }
            .overlay(overlay)
            .listStyle(GroupedListStyle())
            .navigationBarTitle("App Config")
        }
    }
    public var explorer: AppSettingsExplorer {
        return AppSettingsExplorer(configs: containers)
    }
}

struct PreviewAppConfig : AppSettingsConfig {
    func combine(config: PreviewAppConfig?) -> PreviewAppConfig {
        return self
    }
    
    var keyValueRepresentation: [String : String] {
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
    
    var stringValue:String?
    var intValue:Int?
    var boolValue:Bool?
    var doubleValue:Bool?
}
struct AppSettingsExplorer_Previews: PreviewProvider {
    static var previews: some View {
        AppSettings<PreviewAppConfig>().explorer
    }
}

