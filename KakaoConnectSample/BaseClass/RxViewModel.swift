//
//  RxViewModel.swift
//  KakaoConnectSample
//
//  Created by trost.jk on 2022/12/08.
//

import Foundation
import RxSwift
import RxCocoa

protocol RxViewModelProtocol {
    associatedtype Input
    associatedtype Output
    associatedtype Dependency
    
    var input: Input! { get }
    var output: Output! { get }
}

class RxViewModel: NSObject, Deinitializable {
    
    var disposeBag = DisposeBag()
    
    func deinitialize() {
        self.disposeBag = DisposeBag()
    }
    
    override init() {
        super.init()
    }
}
