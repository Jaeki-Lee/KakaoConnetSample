//
//  KakaoVoiceTalkInteractor.swift
//  KakaoConnectSample
//
//  Created by trost.jk on 2022/12/09.
//

import Foundation
import RxSwift

protocol KakaoVoiceTalkInteractorProtocol {
    func getVoiceCallData(parma: VoiceCallDataParams) -> Single<VoiceCallResponseModel>
}

class KakaoVoiceTalkInteractor: KakaoVoiceTalkInteractorProtocol {
    
    let callRepository: CallRepository?
    
    init(callRepository: CallRepository?) {
        self.callRepository = callRepository
    }
    
    func getVoiceCallData(parma: VoiceCallDataParams) -> Single<VoiceCallResponseModel> {
        return self.callRepository!.getVoiceCallData(parma: parma)
    }
}
