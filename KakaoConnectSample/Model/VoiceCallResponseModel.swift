//
//  VoiceCallResponseModel.swift
//  KakaoConnectSample
//
//  Created by trost.jk on 2022/12/09.
//

import Foundation

struct VoiceCallResponseModel {
    var result: Bool?
    var status: Int?
    var message: String?
    var data: VoiceCallData
}

struct VoiceCallData {
    var callerName: String?
    var receiverName: String?
    var roomId: String?
    var isFinished: Bool?
}
