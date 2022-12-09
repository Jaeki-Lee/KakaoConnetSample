//
//  CallRepository.swift
//  KakaoConnectSample
//
//  Created by trost.jk on 2022/12/09.
//

import Foundation
import RxSwift
import RxCocoa
import Moya

protocol CallRepositoryProtocol {
    func getVoiceCallData(parma: VoiceCallDataParams) -> Single<VoiceCallResponseModel>
}

class CallRepository: CallRepositoryProtocol {
    func getVoiceCallData(parma: VoiceCallDataParams) -> Single<VoiceCallResponseModel> {
        let sample = VoiceCallResponseModel(
            result: true,
            status: 200,
            message: "",
            data: VoiceCallData(
                callerName: "상담사",
                receiverName: "내담자",
                roomId: "room_id",
                isFinished: false
            )
        )
        
        return Single.just(sample)
    }
    
}
