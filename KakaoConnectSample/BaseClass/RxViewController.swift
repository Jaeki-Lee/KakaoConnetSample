//
//  RxViewController.swift
//  KakaoConnectSample
//
//  Created by trost.jk on 2022/12/08.
//

import UIKit
import Foundation
import RxSwift
import RxCocoa

class RxViewController<T: RxViewModel>: UIViewController, Deinitializable {
    typealias ViewModel = T
    
    var viewModel: ViewModel!
    
    var disposeBag = DisposeBag()
    
    func deinitialize() {
        self.disposeBag = DisposeBag()
        self.viewModel.deinitialize()
        self.viewModel = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
