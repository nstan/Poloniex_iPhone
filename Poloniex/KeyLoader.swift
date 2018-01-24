
import Foundation

public struct APIKeys {
    let key: String
    let secret: String
}

public struct KeyLoader {
    public static func loadKeys(_ publicKey: String, _ secretKey: String) -> APIKeys? {
        let keychain = KeychainSwift()
        guard let pK = keychain.get(publicKey),
            let sK = keychain.get(secretKey) else {
            print ("No keys stored in keychain")
            return nil
        }
        return APIKeys(key: pK, secret: sK)
    }
}
