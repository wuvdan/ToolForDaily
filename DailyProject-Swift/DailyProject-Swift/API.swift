//
//  API.swift
//  DailyProject-Swift
//
//  Created by wudan on 2021/10/11.
//

/**
 * API 参考地址：https://github.com/MZCretin/RollToolsApi
 * header["app_id"] = "almxgpklqjfuephk"
 * header["app_secret"] = "MlRHaTRPUFZkZzd6U0ZoYmw2ZGJTQT09"
 */
import Foundation
import Moya
import SwiftyJSON

public enum API {
    case dailyWordRecommed
    case chineseCharacterDictionary(String)
    case convertTranslate(String, String, String)
    case newsType
    case newsList(Int, Int)
    case newsDetail(String)
}

extension API: TargetType {
    public var baseURL: URL {
        return URL(string: "https://www.mxnzp.com/api")!
    }
    
    public var path: String {
        switch self {
        case .dailyWordRecommed:
            return "daily_word/recommend"
        case .chineseCharacterDictionary(_):
            return "convert/dictionary"
        case .convertTranslate(_,_,_):
            return "convert/translate"
        case .newsType:
            return "news/types"
        case .newsList(_,_):
            return "news/list"
        case .newsDetail(_):
            return "news/details"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .dailyWordRecommed:
            return .get
        case .chineseCharacterDictionary(_):
            return .get
        case .convertTranslate(_,_,_):
            return .get
        case .newsType:
            return .get
        case .newsList(_, _):
            return .get
        case .newsDetail(_):
            return .get
        }
    }
    
    public var task: Task {
        switch self {
        case .dailyWordRecommed:
            return .requestPlain
        case .chineseCharacterDictionary(let content):
            return .requestParameters(parameters: ["content" : content], encoding: URLEncoding.default)
        case .convertTranslate(let content, let from, let to):
            return .requestParameters(parameters: ["content" : content, "from" : from, "to" : to], encoding: URLEncoding.default)
        case .newsType:
            return .requestPlain
        case .newsList(let typeId, let page):
            return .requestParameters(parameters: ["typeId" : "\(typeId)", "page" : "\(page)"], encoding: URLEncoding.default)
        case .newsDetail(let newsId):
            return .requestParameters(parameters: ["newsId" : newsId], encoding: URLEncoding.default)
        }
    }
    
    public var headers: [String : String]? {
        var header = Dictionary<String , String>()
        header["app_id"] = "almxgpklqjfuephk"
        header["app_secret"] = "MlRHaTRPUFZkZzd6U0ZoYmw2ZGJTQT09"
        return header
    }
}

let apiProvider = MoyaProvider<API>()

struct APIManager {
    struct APIResponse {
        var data: JSON
        var code: Int
        var msg: String
    }
    
    typealias SucceedHandle = (_ res: APIResponse) -> Void
    static func request(target: API, handle:SucceedHandle?) {
        apiProvider.request(target) { result in
            switch result {
            case .success(let success):
                if success.statusCode == 200 {
                    guard let _handle = handle else { return }
                    _handle(APIResponse(data: JSON(JSON(success.data)["data"]), code: JSON(success.data)["code"].intValue, msg: JSON(success.data)["msg"].stringValue))
                    print(JSON(success.data))
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
