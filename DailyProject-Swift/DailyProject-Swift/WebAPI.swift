//
//  API.swift
//  DailyProject-Swift
//
//  Created by wudan on 2021/10/11.
//

import Foundation
import Moya
import SwiftyJSON

public enum WebAPI {
    case upload(String, String, String)
}

extension WebAPI: TargetType {
    public var baseURL: URL {
        return URL(string: "http://script.zhangs.ink/")!
    }
    
    public var path: String {
        switch self {
        case .upload(_,_,_):
            return "jds/update"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .upload(_,_,_):
            return .post
        }
    }
    
    public var task: Task {
        switch self {
        case .upload(_,_,_):
            return .requestPlain
        }
    }
    
    public var headers: [String : String]? {
        switch self {
        case .upload(let pt_key, let pt_pin, let token):
            return ["pt_key" : pt_key, "pt_pin" : pt_pin, "token" : token]
        }
    }
}

let webApiProvider = MoyaProvider<WebAPI>()

struct WebAPIManager {
    struct APIResponse {
        var data: JSON
        var code: Int
        var msg: String
    }
    
    typealias SucceedHandle = (_ res: Bool) -> Void
    static func request(target: WebAPI, handle:SucceedHandle?) {
        webApiProvider.request(target) { result in
            switch result {
            case .success(let success):
                if success.statusCode == 200 {
                    print(JSON(success.data))
                    guard let _handle = handle else { return }
                    if !JSON(success.data).isEmpty {
                        _handle(true)
                    } else {
                        _handle(false)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
