    import XCTest
    @testable import AppSettings

    final class AppSettingsTests: XCTestCase {
        struct TestConfig : Codable, AppSettingsConfig {
            let valueString:String
            let valueInt:Int
            let valueBool:Bool
        }
        func testExample() {
            // This is an example of a functional test case.
            // Use XCTAssert and related functions to verify your tests produce the correct
            // results.

            var dict = [String:Any]()
            dict["valueString"] = "string"
            dict["valueInt"] = 1
            dict["valueBool"] = true
            
            UserDefaults.standard.setValue(dict, forKey: "test")
            if let d2 = UserDefaults.standard.dictionary(forKey: "test") {
                do {
                    let data = try JSONSerialization.data(withJSONObject: d2)
                    let decoder = JSONDecoder()
                    
                    let config = try decoder.decode(TestConfig.self, from: data)
                    XCTAssert(config.valueString == (dict["valueString"] as? String))
                    XCTAssert(config.valueInt == (dict["valueInt"] as? Int))
                    XCTAssert(config.valueBool == (dict["valueBool"] as? Bool))
                }
                catch {
                    XCTFail(error.localizedDescription)
                }
            } else {
                XCTFail("no value")
            }
            
            XCTAssertNotNil(UserDefaults.standard.dictionary(forKey: "test"))
        }
    }
    extension Dictionary {
        
        /// Convert Dictionary to JSON string
        /// - Throws: exception if dictionary cannot be converted to JSON data or when data cannot be converted to UTF8 string
        /// - Returns: JSON string
        func toJson() throws -> Data {
            return try JSONSerialization.data(withJSONObject: self)
        }
    }
