//
//  KakaoVoiceTalkViewController.swift
//  KakaoConnectSample
//
//  Created by trost.jk on 2022/12/08.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then
import ConnectLiveSDK
import AVKit

class KakaoVoiceTalkViewController: RxViewController<KakaoVoiceTalkViewModel> {
    
    static func newInstance(isCaller: Bool) -> KakaoVoiceTalkViewController {
        let vc = Self()
        let viewModel = KakaoVoiceTalkViewModel(
            dependency: KakaoVoiceTalkViewModel.Dependency(
                kakaoVoiceTalkInteractor: KakaoVoiceTalkInteractor(
                    callRepository: CallRepository()
                ),
                userType: isCaller ? .caller : .receiver
            )
        )
        
        vc.viewModel = viewModel
        
        return vc
    }
    
    var config = Config()
    var room: Room?
    var media: LocalMedia?
    
    let exitButton = UIButton().then {
        $0.backgroundColor = .red
        $0.layer.cornerRadius = 12
        $0.setTitle("Exit", for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        $0.setTitleColor(.white, for: .normal)
    }
    
    let routePickerView = AVRoutePickerView().then {
        $0.tintColor = .clear
    }
    
    let routeWayLabel = UILabel().then {
        $0.text = "Calling\nway"
        $0.numberOfLines = 0
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .black
        $0.textAlignment = .center
    }
    
    let callerLabel = KakaoCallLabel().then {
        $0.text = "Caller"
        $0.font = UIFont.boldSystemFont(ofSize: 22)
        $0.textColor = .red
    }
    
    let receiverLabel = KakaoCallLabel().then {
        $0.text = "Receiver"
        $0.font = UIFont.boldSystemFont(ofSize: 22)
        $0.textColor = .red
    }
    
    let cancelButton = UIButton().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.layer.borderWidth = 1.0
        $0.setTitle("Cancel", for: .normal)
        $0.setTitleColor(UIColor.black, for: .normal)
    }
    
    let startButton = UIButton().then {
        $0.backgroundColor = .lightGray
        $0.layer.cornerRadius = 12
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.layer.borderWidth = 1.0
        $0.setTitle("Start", for: .normal)
        $0.setTitleColor(UIColor.gray, for: .normal)
        $0.isEnabled = false
    }
    
    func showAlert(title: String? = nil, message: String, completion: ((UIAlertAction) -> Void)? = nil) {
        DispatchQueue.main.async(execute: {

            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert)

            let action = UIAlertAction(
                title: "확인",
                style: .cancel,
                handler: completion)
            alert.addAction(action)

            self.present(alert, animated: true)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setViews()
        
        self.bindInput()
        self.bindOutput()
        
        self.viewModel.input.loadCallingData.accept(())
    }
    
    private func setViews() {
        self.view.backgroundColor = .white
        
        self.view.addSubview(self.exitButton)
        self.view.addSubview(self.routeWayLabel)
        self.view.addSubview(self.routePickerView)

        self.exitButton.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.height.equalTo(44)
            make.width.equalTo(77)
        }
        
        self.routeWayLabel.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(12)
            make.leading.equalToSuperview().offset(12)
        }
        
        self.routePickerView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(12)
            make.leading.equalToSuperview().offset(12)
            make.height.equalTo(44)
            make.width.equalTo(77)
        }
        
        let callerReceiverStackView = UIStackView(arrangedSubviews: [self.callerLabel, self.receiverLabel])
        callerReceiverStackView.axis = .horizontal
        callerReceiverStackView.distribution = .fillEqually
        callerReceiverStackView.spacing = 100
        
        self.view.addSubview(callerReceiverStackView)
        
        callerReceiverStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        let cancelStartStackView = UIStackView(arrangedSubviews: [self.cancelButton, self.startButton])
        cancelStartStackView.axis = .horizontal
        cancelStartStackView.distribution = .fillEqually
        cancelStartStackView.spacing = 10
        
        self.view.addSubview(cancelStartStackView)
        
        cancelStartStackView.snp.makeConstraints { make in
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.height.equalTo(40)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
    private func bindInput() {
        
        self.startButton.rx.controlEvent(.touchUpInside)
            .withUnretained(self)
            .subscribe { (self, _) in
                self.viewModel.input.requestCalling.accept(.전화시작)
            }.disposed(by: self.disposeBag)
            
        
    }
    
    private func bindOutput() {
        self.viewModel.output
            .loadCallingDataComplete
            .withUnretained(self)
            .emit { (self, voiceCallData) in
                
                guard let roomId = voiceCallData.roomId else { return }
                
                self.initAndConnectKakaoLive(roomId: roomId)
                
                if let callerName = voiceCallData.callerName, let receiverName = voiceCallData.receiverName {
                    self.callerLabel.text = callerName
                    self.receiverLabel.text = receiverName
                }
                
                if self.viewModel.dependency.userType == .caller {
                    self.callerLabel.callerName = voiceCallData.callerName
                    self.callerLabel.setCallerName()
                }
                
                if self.viewModel.dependency.userType == .receiver {
                    self.receiverLabel.receiverName = voiceCallData.receiverName
                    self.receiverLabel.setReceiverName()
                }
                
            }
            .disposed(by: self.disposeBag)
        
        self.viewModel.output
            .stateChanged
            .withUnretained(self)
            .emit { (self, state) in
                //전화 거는 사람의 UI 변경
                if self.viewModel.dependency.userType == .caller {
                    switch (state) {
                    case .미연결:
                        print("상담사 미연결 상태 UI")
                    case .입장대기:
                        print("상담사 입장대기 상태 UI")
                    case .상담시작_전:
                        print("상담사 입장대기 상태 UI")
                    case .상담중:
                        print("상담사 상담중 상태 UI")
                    case .상담시작_전_상대_나감:
                        print("상담사 시작 전 상대 나감 상태 UI")
                    case .상담중_상대_나감:
                        print("상담사 상담중 상대 나감 상태 UI")
                    }
                //전화 받는 사람의 UI 변경
                } else if self.viewModel.dependency.userType == .receiver {
                    switch (state) {
                    case .미연결:
                        print("내담자 미연결 상태 UI")
                    case .입장대기:
                        print("내담자 입장대기 상태 UI")
                    case .상담시작_전:
                        print("내담자 입장대기 상태 UI")
                    case .상담중:
                        print("내담자 상담중 상태 UI")
                    case .상담시작_전_상대_나감:
                        print("내담자 시작 전 상대 나감 상태 UI")
                    case .상담중_상대_나감:
                        print("내담자 상담중 상대 나감 상태 UI")
                    }
                }
            }.disposed(by: self.disposeBag)
        
        self.viewModel.output
            .errorAlert
            .withUnretained(self)
            .emit { (self, errorMessage) in
                self.showAlert(message: errorMessage)
            }.disposed(by: self.disposeBag)
    }
    
    fileprivate func initAndConnectKakaoLive(roomId: String) {
        let serviceId = "serviceID"
        let serviceSecret = "Service Secret"
        
        ConnectLive.setAudioSessionConfiguration(
            category: .playAndRecord,
            mode: .voiceChat,
            options: [.mixWithOthers, .defaultToSpeaker, .allowBluetooth]
        )
        
        ConnectLive.signIn(serviceId: serviceId, serviceSecret: serviceSecret) { [weak self] code, message in
            guard let self else { return }
            
            if code == 0 {
                self.connectRoom(roomId: roomId)
            }
        }
    }
    
    fileprivate func connectRoom(roomId: String) {
        self.config.mediaOptions.audio = true
        self.config.mediaOptions.video = false
        self.config.mediaOptions.hasAudio = true
        self.config.mediaOptions.hasVideo = false
        
        guard let media = ConnectLive.createLocalMedia(config: config) else { return }
        
        media.start { error in }
        
        media.audio.alwaysOn = true
        
        self.media = media
        
        let room = ConnectLive.createRoom(config: config, delegate: self.viewModel)
        
        room.connect(roomId: roomId)
        
        try? room.publish(self.media)
        
        self.room = room
    }
    
}

class KakaoCallLabel: UILabel {
    var callerName: String?
    var receiverName: String?
    
    func setCallerName() {
        if let callerName = self.callerName {
            self.text = callerName
        }
    }
    
    func setReceiverName() {
        if let receiverName = self.receiverName {
            self.text = receiverName
        }
    }
}
