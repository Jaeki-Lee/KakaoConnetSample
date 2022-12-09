//
//  CallAPI.swift
//  KakaoConnectSample
//
//  Created by trost.jk on 2022/12/09.
//

import RxSwift
import RxMoya
import Moya
import Alamofire
import Then
import Foundation

enum CallAPI {
    case getVoiceCallData(VoiceCallDataParams)
    case getFaceCallData(FaceCallDataParams)
}

extension CallAPI: Moya.TargetType {
    
    static let moya = MoyaWrapper.provider
    
    var baseURL: URL {
        return URL(string: "https://callAPI")!
    }
    
    var path: String {
        switch self {
        case .getVoiceCallData(let voiceCallDataParams):
            return "/voice"
        case .getFaceCallData(let faceCallDataParams):
            return "/face"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getVoiceCallData(let voiceCallDataParams):
            return .get
        case .getFaceCallData(let faceCallDataParams):
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getVoiceCallData(let voiceCallDataParams):
            return .requestJSONEncodable(voiceCallDataParams)
        case .getFaceCallData(let faceCallDataParams):
            return .requestJSONEncodable(faceCallDataParams)
        }
    }
    
    var headers: [String : String]? {
        return [
            "Api-Configure": "Production",
        ]
    }
    
    private enum MoyaWrapper {
        struct Plugins {
            var plugins: [PluginType]
            
            init(plugins: [PluginType]) {
                self.plugins = plugins
            }
            
            func callAsFunction() -> [PluginType] { self.plugins }
        }
        
        static var provider: MoyaProvider<CallAPI> {
            let plugins = Plugins(plugins: [])
            
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 120
            configuration.urlCredentialStorage = nil
            
            let session = Session(configuration: configuration)
            
            return MoyaProvider<CallAPI>(
            endpointClosure: { targetType in
                MoyaProvider.defaultEndpointMapping(for: targetType)
            },
            session: session,
            plugins: plugins.callAsFunction()
            )
        }
    }
    
}

extension CallAPI {
    func request() -> Single<Response> {
        return Self.moya.rx.request(self)
            .do { response in
                print(response)
            } onError: { rawError in
                print(rawError)
            }
    }
}


struct VoiceCallDataParams: Codable {
    let type = "voice"
}

struct FaceCallDataParams: Codable {
    let type = "face"
}

extension TargetType {
    static func convertToURLError(_ error: Error) -> URLError? {
        switch error {
        case let MoyaError.underlying(afError as AFError, _):
            fallthrough
        case let afError as AFError:
            return afError.underlyingError as? URLError
        case let MoyaError.underlying(urlError as URLError, _):
            return urlError
        case let urlError as URLError:
            return urlError
        default:
            return nil
        }
    }
    
    static func isNotConnection(error: Error) -> Bool {
        Self.convertToURLError(error)?.code == .notConnectedToInternet
    }
    
    static func isLostConnection(error: Error) -> Bool {
        switch error {
        case let AFError.sessionTaskFailed(error: posixError as POSIXError)
          where posixError.code == .ECONNABORTED: // eConnAboarted: Software caused connection abort.
          break
        case let MoyaError.underlying(urlError as URLError, _):
          fallthrough
        case let urlError as URLError:
          guard urlError.code == URLError.networkConnectionLost else { fallthrough } // A client or server connection was severed in the middle of an in-progress load.
          break
        default:
          return false
        }
        return true
      }
}
