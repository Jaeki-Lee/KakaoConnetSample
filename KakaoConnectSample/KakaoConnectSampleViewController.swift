//
//  KakaoConnectSample.swift
//  KakaoConnectSample
//
//  Created by trost.jk on 2022/12/08.
//

import UIKit
import SnapKit
import Then

class KakaoConnectSampleViewController: UIViewController {
    
    let itemList: [KakaoConnectItem] = [
        KakaoConnectItem(
            title: "Voice talk item for caller",
            itemController: KakaoVoiceTalkViewController.newInstance(isCaller: true)
        ),
        KakaoConnectItem(
            title: "Voice talk item for receiver",
            itemController: KakaoVoiceTalkViewController()
        ),
        KakaoConnectItem(
            title: "Face talk item",
            itemController: UIViewController()
        )
    ]
    
    lazy var kakoConnectItemTableView = UITableView().then {
        $0.backgroundColor = .white
        $0.delegate = self
        $0.dataSource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        self.setViews()
    }
    
    private func setViews() {
        self.view.addSubview(self.kakoConnectItemTableView)
        
        self.makeConstraints()
    }
    
    private func makeConstraints() {
        self.kakoConnectItemTableView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalTo(self.view.safeAreaInsets)
        }
    }
}

extension KakaoConnectSampleViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let kakaoItem = self.itemList[indexPath.row]
        
        let tableViewCell = UITableViewCell()
        tableViewCell.textLabel?.text = kakaoItem.title
        
        return tableViewCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let kakaoItem = self.itemList[indexPath.row]
        
        self.navigationController?.pushViewController(kakaoItem.itemController, animated: true)
    }
    
}

struct KakaoConnectItem {
    let title: String
    let itemController: UIViewController
}

