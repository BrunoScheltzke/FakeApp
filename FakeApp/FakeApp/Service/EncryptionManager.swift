//
//  EncryptionManager.swift
//  FakeApp
//
//  Created by Bruno Scheltzke on 09/10/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import Foundation
import CryptoSwift

class EncryptionManager {
    private var privateKey: SecKey!
    private var publicKey: SecKey!
    
    private var publicKeyString: String?
    
    private let privateKeyTag = "privateKeyTag"
    
    func getPublicKey() -> (key: String?, error: Error?) {
        if let key = publicKeyString { return (key, nil) }
        
        //verify if there are keys on keychain
        if let key = getExistingPrivateKey() {
            privateKey = key
        } else {
            let result = createPrivateKey()
            guard let key = result.key else {
                return (nil, result.error)
            }
            privateKey = key
        }
        
        //get public key
        let resultOfPublicKey = getPublicExternalRepresentation(of: privateKey)
        guard let publicKey = resultOfPublicKey.key else {
            return (nil, resultOfPublicKey.error)
        }
        return (publicKey, nil)
    }
    
    // MARK: Retrieve private key
    func getExistingPrivateKey() -> SecKey? {
        let getExistingPrivateKeyQuery: [String: Any] = [kSecClass as String: kSecClassKey,
                                                         kSecAttrApplicationTag as String: privateKeyTag,
                                                         kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                                                         kSecReturnRef as String: true]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(getExistingPrivateKeyQuery as CFDictionary, &item)
        if status == errSecSuccess {
            let key = item as! SecKey
            return key
        } else {
            //private key does not exit
            return nil
        }
    }
    
    func getPublicExternalRepresentation(of key: SecKey) -> (key: String?, error: Error?) {
        //generate public key and temporarely store it in this instance privately
        publicKey = SecKeyCopyPublicKey(key)
        
        //get public key external representation
        var error3: Unmanaged<CFError>?
        guard let dataKey = SecKeyCopyExternalRepresentation(publicKey, &error3) as Data? else {
            return (nil, error3!.takeRetainedValue() as Error)
        }
        
        let keyString = dataKey.base64EncodedString()
        publicKeyString = keyString
        
        return (keyString, nil)
    }
    
    // MARK: Create private key
    func createPrivateKey() -> (key: SecKey?, error: Error?) {
        //generate private key and store it on keychain
        let attributes: CFDictionary =
            [kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
             kSecAttrKeySizeInBits as String: 1024,
             kSecPrivateKeyAttrs as String:
                [kSecAttrIsPermanent as String: true,
                 kSecAttrApplicationTag as String: privateKeyTag]] as CFDictionary
        
        var error: Unmanaged<CFError>?
        guard let generatedKey = SecKeyCreateRandomKey(attributes, &error) else {
            return (nil, error!.takeRetainedValue() as Error)
        }
        
        return (generatedKey, nil)
    }
    
    func sign(_ data: Data) -> (signature: Data?, error: Error?) {
        var error: Unmanaged<CFError>?
        guard let signature = SecKeyCreateSignature(privateKey,
                                                    SecKeyAlgorithm.rsaSignatureMessagePKCS1v15SHA256,
                                                    data as CFData,
                                                    &error) as Data? else {
                                                        return (nil, error!.takeRetainedValue() as Error)
        }
        
        return (signature, nil)
    }
    
    func encrypt(_ data: Data, withKey key: [UInt8]) -> String? {
        //encrypt with aes key
        do {
            let iv = "4242424242424242".toArrayUInt8()
            let blockMode = CBC(iv: iv)
            let aes = try AES(key: key, blockMode: blockMode)
            let ciphertext = try aes.encrypt(data.bytes)
            
            return Data(ciphertext).base64EncodedString()
        } catch {
            return nil
        }
    }
    
    func decrypt(_ data: Data) -> (value: [UInt8]?, error: Error?) {
        var error4: Unmanaged<CFError>?
        guard let clearText = SecKeyCreateDecryptedData(self.privateKey,
                                                        SecKeyAlgorithm.rsaEncryptionRaw,
                                                        data as CFData,
                                                        &error4) as Data? else {
                                                            let dasError =  error4!.takeRetainedValue() as Error
                                                            return (nil, dasError)
        }
        
        let result = Array(clearText.bytes.suffix(32))
        return (result, nil)
    }
}
