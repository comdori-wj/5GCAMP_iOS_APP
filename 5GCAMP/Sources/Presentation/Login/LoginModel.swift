//
//  LoginModel.swift
//  5GCAMP
//
//  Created by WONJI HA on 12/2/24.
//

import Foundation

struct LoginModel: Codable {
    let status: Bool
    let message: String
    let uid: String?
    let nic: String?
    let email: String?
    let photo: String?
    let point: String?
    let scrap: String?
    let conquest: String?
    let camp0: String?
    let camp1: String?
    let camp2: String?
    let camp3: String?
    
    // 디코딩 실패 시 기본값 제공
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decodeIfPresent(Bool.self, forKey: .status) ?? false
        message = try container.decodeIfPresent(String.self, forKey: .message) ?? ""
        uid = try container.decodeIfPresent(String.self, forKey: .uid)
        nic = try container.decodeIfPresent(String.self, forKey: .nic)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        photo = try container.decodeIfPresent(String.self, forKey: .photo)
        point = try container.decodeIfPresent(String.self, forKey: .point)
        scrap = try container.decodeIfPresent(String.self, forKey: .scrap)
        conquest = try container.decodeIfPresent(String.self, forKey: .conquest)
        camp0 = try container.decodeIfPresent(String.self, forKey: .camp0)
        camp1 = try container.decodeIfPresent(String.self, forKey: .camp1)
        camp2 = try container.decodeIfPresent(String.self, forKey: .camp2)
        camp3 = try container.decodeIfPresent(String.self, forKey: .camp3)
    }
}
