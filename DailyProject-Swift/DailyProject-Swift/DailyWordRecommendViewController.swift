//
//  DailyWordRecommendViewController.swift
//  DailyProject-Swift
//
//  Created by wudan on 2021/10/11.
//

import UIKit
import SwiftyJSON
import Kingfisher
import UIImageColors

// https://api.mz-moe.cn/img.php
fileprivate struct DailyWordRecommendModel {
    /// 内容
    var content: String
    /// 作者
    var author: String
    
    init(_ jsonData: JSON) {
        author = jsonData["author"].stringValue
        content = jsonData["content"].stringValue
    }
}

class DailyWordRecommendViewController: UIViewController {

    fileprivate lazy var backgroundImageView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        view.addSubview(img)
        return img
    }()
    
    fileprivate lazy var contentLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.textColor = .white
        l.font = .systemFont(ofSize: 20)
        l.numberOfLines = 0
        view.addSubview(l)
        return l
    }()
    
    fileprivate lazy var autherLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .right
        l.textColor = .white
        l.font = .systemFont(ofSize: 18)
        l.numberOfLines = 0
        view.addSubview(l)
        return l
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        backgroundImageView.kf.setImage(with: URL(string:"https://picsum.photos//1080/1920?blur=3"), placeholder: nil, options:  [
            .scaleFactor(UIScreen.main.scale),
            .transition(.fade(1)),
            .forceRefresh
        ]) { res in
            DispatchQueue.main.async {
                self.backgroundImageView.image?.getColors({ colors in
                    self.contentLabel.textColor = .white
                    self.autherLabel.textColor = .white
                })
            }
        }
        
        DispatchQueue.global().async {
            APIManager.request(target: .dailyWordRecommed) { res in
                DispatchQueue.main.async {
                    if res.code == 1 {
                        let model = DailyWordRecommendModel(res.data.arrayValue.first!)
                        self.contentLabel.text = model.content
                        self.autherLabel.text = model.author.count > 0 ? "---" + model.author : model.author
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(30)
            make.centerY.equalToSuperview()
        }
        
        autherLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(30)
            make.top.equalTo(contentLabel.snp.bottom)
        }
    }
}
