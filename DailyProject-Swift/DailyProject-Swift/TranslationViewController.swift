//
//  TranslationViewController.swift
//  DailyProject-Swift
//
//  Created by wudan on 2021/10/12.
//

import UIKit
import CSPickerView
import SwiftyJSON

fileprivate struct TranslationModel {
    var resultLanguage: String
    var result: String
    var originLanguage: String
    var origin: String
    
    init(_ jsonData: JSON) {
        resultLanguage = jsonData["resultLanguage"].stringValue
        result = jsonData["result"].stringValue
        originLanguage = jsonData["originLanguage"].stringValue
        origin = jsonData["origin"].stringValue
    }
}

class TranslationViewController: UIViewController {
    
    fileprivate struct Item {
        var name: String
        var code: String
    }
    
    fileprivate let items: Array<Item> = [
        Item(name: "中文", code: "zh"),
        Item(name: "英文", code: "en"),
        Item(name: "繁体中文", code: "cht"),
        Item(name: "粤语", code: "yue"),
        Item(name: "文言文", code: "wyw"),
        Item(name: "日语", code: "jp"),
        Item(name: "韩语", code: "kor"),
        Item(name: "法语", code: "fra"),
        Item(name: "西班牙语", code: "spa"),
        Item(name: "泰语", code: "th"),
        Item(name: "阿拉伯语", code: "ara"),
        Item(name: "俄语", code: "ru"),
        Item(name: "葡萄牙语", code: "pt"),
        Item(name: "德语", code: "de"),
        Item(name: "意大利语", code: "it"),
        Item(name: "希腊语", code: "el"),
        Item(name: "荷兰语", code: "nl"),
        Item(name: "波兰语", code: "pl"),
        Item(name: "保加利亚语", code: "bul"),
        Item(name: "爱沙尼亚语", code: "est"),
        Item(name: "丹麦语", code: "dan"),
        Item(name: "芬兰语", code: "fin"),
        Item(name: "捷克语", code: "cs"),
        Item(name: "罗马尼亚语", code: "rom"),
        Item(name: "斯洛文尼亚语", code: "slo"),
        Item(name: "瑞典语", code: "swe"),
        Item(name: "匈牙利语", code: "hu"),
        Item(name: "越南语", code: "vie"),
    ]

    lazy var upButton: UIButton = {
        let t = UIButton()
        t.setTitle(items.first?.name, for: .normal)
        t.setTitleColor(.systemBlue, for: .normal)
        t.addTarget(self, action: #selector(didTappedSelectWayUp(sender:)), for: .touchUpInside)
        t.setImage(.init(named: "icon_arrow_down"), for: .normal)
        view.addSubview(t)
        return t
    }()
    
    lazy var downButton: UIButton = {
        let t = UIButton()
        t.setTitle(items[1].name, for: .normal)
        t.setTitleColor(.systemBlue, for: .normal)
        t.addTarget(self, action: #selector(didTappedSelectWayDown(sender:)), for: .touchUpInside)
        t.setImage(.init(named: "icon_arrow_down"), for: .normal)
        view.addSubview(t)
        return t
    }()
    
    lazy var upTextView: UITextView = {
        let t = UITextView()
        t.layer.borderWidth = 0.5
        t.layer.borderColor = UIColor(red: 233/255.0, green: 233/255.0, blue: 233/255.0, alpha: 1).cgColor
        t.layer.cornerRadius = 10
        t.text = "我爱你！中国"
        view.addSubview(t)
        return t
    }()
        
    lazy var downTextView: UITextView = {
        let t = UITextView()
        t.layer.borderWidth = 0.5
        t.layer.borderColor = UIColor(red: 233/255.0, green: 233/255.0, blue: 233/255.0, alpha: 1).cgColor
        t.layer.cornerRadius = 10
        view.addSubview(t)
        return t
    }()
    
    fileprivate var upItem = Item(name: "中文", code: "zh")
    fileprivate var downItem = Item(name: "英文", code: "en")

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "翻译"
        view.backgroundColor = .white
        
        APIManager.request(target: .convertTranslate("我爱你！中国", upItem.code, downItem.code)) { [weak self] res in
            guard let weakself = self else { return }
            DispatchQueue.main.async {
                if res.code == 1 {
                    let model = TranslationModel(res.data)
                    weakself.downTextView.text = model.result
                } else {
                    
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func didTappedSelectWayUp(sender: Any) {
        PickerViewManager.showSingleColPicker("请选择语言", data: items.map({
            return $0.name
        }), defaultSelectedIndex: 0, cancelAction: nil) { index, name in
            self.upItem = self.items[index]
            self.upButton.setTitle(name, for: .normal)
        }
    }
    
    @objc func didTappedSelectWayDown(sender: Any) {
        PickerViewManager.showSingleColPicker("请选择语言", data: items.map({
            return $0.name
        }), defaultSelectedIndex: 0, cancelAction: nil) { index, name in
            self.downItem = self.items[index]
            self.downButton.setTitle(name, for: .normal)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
                
        upButton.snp.makeConstraints { make in
            make.top.equalTo(88)
            make.leading.equalToSuperview().inset(15)
            make.width.equalTo((UIScreen.main.bounds.size.width - 15 - 50) * 0.5)
            make.height.equalTo(40)
        }
        
        downButton.snp.makeConstraints { make in
            make.top.equalTo(88)
            make.trailing.equalToSuperview().inset(15)
            make.height.equalTo(40)
            make.width.equalTo((UIScreen.main.bounds.size.width - 15 - 50) * 0.5)
        }
//        upTextView.snp.makeConstraints { make in
//            make.top.equalTo(upButton.snp.bottom)
//            make.leading.trailing.equalToSuperview().inset(15)
//            make.height.equalTo((UIScreen.main.bounds.size.height - 88.0 - 40 * 2.0 - 180) / 2.0)
//        }
//
//
//
//        downTextView.snp.makeConstraints { make in
//            make.top.equalTo(downButton.snp.bottom)
//            make.leading.trailing.equalToSuperview().inset(15)
//            make.height.equalTo((UIScreen.main.bounds.size.height - 88.0 - 40 * 2.0 - 180) / 2.0)
//        }
    }
}
