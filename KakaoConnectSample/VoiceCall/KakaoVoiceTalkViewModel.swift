//
//  KakaoVoiceTalkViewModel.swift
//  KakaoConnectSample
//
//  Created by trost.jk on 2022/12/08.
//

import Foundation
import RxSwift
import RxCocoa
import ConnectLiveSDK

class KakaoVoiceTalkViewModel: RxViewModel, RxViewModelProtocol {
    struct Input {
        let loadCallingData: PublishRelay<Void>
        let requestCalling: PublishRelay<RequestCalling>
    }
    
    struct Output {
        let loadCallingDataComplete: Signal<VoiceCallData>
        let stateChanged: Signal<State>
        let dismiss: Signal<Bool>
        let errorAlert: Signal<String>
    }
    
    struct Dependency {
        let kakaoVoiceTalkInteractor: KakaoVoiceTalkInteractorProtocol
        let userType: UserType
    }
    
    var input: KakaoVoiceTalkViewModel.Input!
    var output: KakaoVoiceTalkViewModel.Output!
    var dependency: KakaoVoiceTalkViewModel.Dependency!
    
    var loadCallingDataRelay = PublishRelay<Void>()
    var requestCallingRelay = PublishRelay<RequestCalling>()
    
    var loadCallingDataCompletedRelay = PublishRelay<VoiceCallData>()
    var stateChangedRelay = PublishRelay<State>()
    var dismissRelay = PublishRelay<Bool>()
    var errorAlertRelay = PublishRelay<String>()
    
    var state: State = .미연결
    var voiceCallData: VoiceCallData?
    
    init(dependency: Dependency) {
        super.init()
        
        self.input = KakaoVoiceTalkViewModel.Input(
            loadCallingData: self.loadCallingDataRelay,
            requestCalling: self.requestCallingRelay
        )
        
        self.output = KakaoVoiceTalkViewModel.Output(
            loadCallingDataComplete: self.loadCallingDataCompletedRelay.asSignal(),
            stateChanged: self.stateChangedRelay.asSignal(),
            dismiss: self.dismissRelay.asSignal(),
            errorAlert: self.errorAlertRelay.asSignal()
        )
        
        self.dependency = dependency
        
        self.bindInputs()
        self.bindOutputs()
    }
    
    private func bindInputs() {
        self.loadCallingDataRelay
            .withUnretained(self)
            .subscribe { (self, _) in
                self.dependency.kakaoVoiceTalkInteractor
                    .getVoiceCallData(parma: VoiceCallDataParams())
                    .asObservable()
                    .withUnretained(self)
                    .subscribe { (self, response) in
                        guard let status = response.status else { return }
                        
                        if status >= 200 && status < 300 {
                            self.voiceCallData = response.data
                            self.loadCallingDataCompletedRelay.accept(response.data)
                        }
                    }.disposed(by: self.disposeBag)
            }.disposed(by: self.disposeBag)
        
        self.requestCallingRelay
            .withUnretained(self)
            .subscribe { (self, requestType) in
                //앱 서버 API 안에서 알아야 한다면 API 통신
                
                //앱 서버 API 통신이 성공 이라면
                if requestType == .전화시작 {
                    self.state = .상담중
                    self.stateChangedRelay.accept(self.state)
                } else {
                    self.dismissRelay.accept(true)
                }
            }.disposed(by: self.disposeBag)
        
    }
    
    private func bindOutputs() {
        
    }
}


extension KakaoVoiceTalkViewModel: RoomDelegate {
    func onConnected(participantIds: [String]) {
        self.state = participantIds.count > 1 ? .상담시작_전 : .입장대기
        self.stateChangedRelay.accept(self.state)
    }
    
    func onDisconnected(reason: ConnectLiveSDK.DisconnectReason) {
        self.errorAlertRelay.accept("연결이 끊어졌습니다.재입장 해주세요.")
    }
    
    func onError(code: Int, message: String, isCritical: Bool) {
        self.errorAlertRelay.accept(message)
    }
    
    func onParticipantEntered(remoteParticipant: ConnectLiveSDK.RemoteParticipant) {
        if self.state == .입장대기 || self.state == .상담시작_전_상대_나감 {
            self.state = .상담시작_전
            self.stateChangedRelay.accept(self.state)
        } else if self.state == .상담중_상대_나감 {
            self.state = .상담중
            self.stateChangedRelay.accept(self.state)
        }
    }
    
    func onParticipantLeft(remoteParticipant: ConnectLiveSDK.RemoteParticipant) {
        if self.state == .상담중 {
            self.state = .상담중_상대_나감
        } else {
            self.state = .상담시작_전_상대_나감
        }
        
        self.stateChangedRelay.accept(self.state)
    }
    
    
}

enum UserType {
    case caller, receiver
    
    var APIString: String {
        switch self {
        case .caller:
            return "caller"
        case .receiver:
            return "receiver"
        }
    }
}

enum State {
    case 미연결, 입장대기, 상담시작_전, 상담중, 상담시작_전_상대_나감, 상담중_상대_나감
}

enum RequestCalling {
    case 전화시작, 전화취소, 전화종료
}
