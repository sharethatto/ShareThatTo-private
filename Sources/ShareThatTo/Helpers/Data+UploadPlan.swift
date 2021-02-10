//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/5/21.
//

import CommonCrypto
import Foundation

extension Data
{
    func uploadPlan(contentType: String) -> UploadPlanRequest
    {
        return UploadPlanRequest(byte_size: count, checksum: md5Base64, content_type: contentType)
    }
    
    var md5Base64 : String {
           var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
           _ =  self.withUnsafeBytes { bytes in
               CC_MD5(bytes, CC_LONG(self.count), &digest)
           }
           let digestData = NSData(bytes: digest, length: Int(CC_MD5_DIGEST_LENGTH))
           return digestData.base64EncodedString(options: [])
       }
}
