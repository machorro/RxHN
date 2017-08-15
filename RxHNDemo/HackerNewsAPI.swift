//
//  API.swift
//  RxHNDemo
//
//  Created by humbertog on 2017-08-01.
//  Copyright © 2017 humbertog. All rights reserved.
//

import Moya

enum HackerNews {
    typealias HNid = UInt64
    
    case new
    case best
    case top
    case item(id: HNid)
}

extension HackerNews: TargetType {
    var baseURL: URL { return URL(string: "https://hacker-news.firebaseio.com/v0/")! }
    
    var path: String {
        switch self {
        case .new:
            return "newstories.json"
        case .best:
            return "beststories.json"
        case .top:
            return "topstories.json"
        case .item(let id):
            return "item/\(id).json"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .new, .best, .top, .item(_):
            return .get
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .new, .best, .top, .item(_):
            return nil
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .new, .best, .top, .item(_):
            return JSONEncoding.default
        }
    }
    
    var sampleData: Data {
        switch self {
        case .new, .best, .top:
            return "[14902696, 14903873, 14903071, 14903775, 14904107, 14902630, 14904149, 14900615, 14901313]".utf8Encoded
        case .item(_):
            return """
                {
                    "by" : "dhouston",
                    "descendants" : 71,
                    "id" : 8863,
                    "kids" : [ 8952, 9224, 8917, 8884, 8887, 8943, 8869, 8958, 9005, 9671, 9067, 8940, 8908, 9055, 8865, 8881, 8872, 8873, 8955, 10403, 8903, 8928, 9125, 8998, 8901, 8902, 8907, 8894, 8878, 8980, 8870, 8934, 8876 ],
                    "score" : 111,
                    "time" : 1175714200,
                    "title" : "My YC app: Dropbox - Throw away your USB drive",
                    "type" : "story",
                    "url" : "http://www.getdropbox.com/u/2/screencast.html"
                }
""".utf8Encoded
        }
    }
    
    var task: Task {
        switch self {
        case .new, .best, .top, .item(_):
            return .request
        }
    }
}

// MARK: - Helpers
private extension String {
    var urlEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var utf8Encoded: Data {
        return self.data(using: .utf8)!
    }
}
