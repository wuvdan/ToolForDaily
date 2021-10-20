//
//  ChineseCharacterDictionaryViewController.swift
//  DailyProject-Swift
//
//  Created by wudan on 2021/10/12.
//

import UIKit
import SwiftyJSON

class ChineseCharacterDictionaryItemCell: UITableViewCell {
    
    fileprivate lazy var bgImageView: UIImageView = {
        let img = UIImageView()
        img.image = .init(named: "icon_chinese_character_bg")
        img.contentMode = .scaleAspectFit
        contentView.addSubview(img)
        return img
    }()
    
    fileprivate lazy var contentLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.textColor = .black
        l.font = .init(name: "STKaiti", size: 60)
        l.numberOfLines = 0
        bgImageView.addSubview(l)
        return l
    }()
    
    fileprivate lazy var pinyinLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .left
        l.textColor = .black
        l.font = .init(name: "STKaiti", size: 15)
        l.numberOfLines = 0
        contentView.addSubview(l)
        return l
    }()
    
    fileprivate lazy var strokesLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .left
        l.textColor = .black
        l.font = .init(name: "STKaiti", size: 15)
        l.numberOfLines = 0
        contentView.addSubview(l)
        return l
    }()
    
    fileprivate lazy var radicalsLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .left
        l.textColor = .black
        l.font = .init(name: "STKaiti", size: 15)
        l.numberOfLines = 0
        contentView.addSubview(l)
        return l
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bgImageView.snp.makeConstraints { make in
            make.leading.equalTo(30)
            make.top.equalTo(10)
            make.bottom.equalTo(-10)
            make.height.width.equalTo(80)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        pinyinLabel.snp.makeConstraints { make in
            make.leading.equalTo(contentLabel.snp.trailing).offset(15)
            make.top.equalTo(bgImageView)
        }
        
        radicalsLabel.snp.makeConstraints { make in
            make.leading.equalTo(contentLabel.snp.trailing).offset(15)
            make.centerY.equalTo(bgImageView)
        }
        
        strokesLabel.snp.makeConstraints { make in
            make.leading.equalTo(contentLabel.snp.trailing).offset(15)
            make.bottom.equalTo(bgImageView)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate struct ChineseCharacterDictionaryModel {
    /// 偏旁
    var radicals: String
    /// 解释
    var explanation: String
    /// 拼音
    var pinyin: String
    /// 笔画
    var strokes: Int
    /// 繁体字
    var traditional: String
    /// 组词
    var word: String
    
    init(_ jsonData: JSON) {
        radicals = jsonData["radicals"].stringValue
        explanation = jsonData["explanation"].stringValue
        pinyin = jsonData["pinyin"].stringValue
        strokes = jsonData["strokes"].intValue
        explanation = jsonData["explanation"].stringValue
        traditional = jsonData["traditional"].stringValue
        word = jsonData["word"].stringValue
    }
}

class ChineseCharacterDictionaryViewController: UIViewController {

    lazy var textFiled: UITextField = {
        let t = UITextField()
        t.placeholder = "请输入单个汉字..."
        t.borderStyle = .roundedRect
        t.returnKeyType = .search
        t.delegate = self
        t.textAlignment = .center
        t.font = .init(name: "STKaiti", size: 15)
        view.addSubview(t)
        return t
    }()
    
    fileprivate lazy var tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        t.delegate = self
        t.dataSource = self
        t.rowHeight = UITableView.automaticDimension
        t.estimatedRowHeight = 100.0
//        t.sectionHeaderTopPadding = 0
        t.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        t.register(ChineseCharacterDictionaryItemCell.self, forCellReuseIdentifier: "ChineseCharacterDictionaryItemCell")
        t.separatorStyle = .none
        view.addSubview(t)
        return t
    }()
    
    fileprivate var dataModel: ChineseCharacterDictionaryModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "汉字字典"
        APIManager.request(target: .chineseCharacterDictionary("妍")) { [weak self] res in
            guard let weakself = self else { return}
            DispatchQueue.main.async {
                if res.code == 1 {
                    weakself.dataModel = ChineseCharacterDictionaryModel(res.data.arrayValue.first!)
                    weakself.tableView.reloadData()
                } else {
                    
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textFiled.snp.makeConstraints { make in
            make.leading.equalTo(30)
            make.trailing.equalTo(-30)
            make.top.equalTo(98)
            make.height.equalTo(40)
        }
        
        tableView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(textFiled.snp.bottom)
        }
    }
}

extension ChineseCharacterDictionaryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.text?.count ?? 0 > 0 {
            APIManager.request(target: .chineseCharacterDictionary(textField.text ?? "")) { res in
                DispatchQueue.main.async {
                    if res.code == 1 {
                        self.dataModel = ChineseCharacterDictionaryModel(res.data.arrayValue.first!)
                        self.tableView.reloadData()
                    } else {
                        
                    }
                }
            }
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        if !isPureChinese(string: text) { return true }
        return text.count + string.count - range.length <= 1
    }
    
    func isPureChinese(string: String) -> Bool {
        let match: String = "[\\u4e00-\\u9fa5]+$"
        let predicate = NSPredicate(format: "SELF matches %@", match)
        return predicate.evaluate(with: string)
    }
}

extension ChineseCharacterDictionaryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if (dataModel != nil) {
            return 2
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChineseCharacterDictionaryItemCell", for: indexPath) as! ChineseCharacterDictionaryItemCell
            cell.contentLabel.text = dataModel?.traditional
            cell.pinyinLabel.text = "拼音: " + dataModel!.pinyin
            cell.radicalsLabel.text = "偏旁: " + dataModel!.radicals
            cell.strokesLabel.text = "笔画: " + "\(dataModel!.strokes)"
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.textLabel?.text = dataModel!.explanation.replacingOccurrences(of: "\n", with: "")
        cell.textLabel?.numberOfLines = 0
        cell.selectionStyle = .none
        cell.textLabel?.font = .init(name: "STKaiti", size: 18)
        return cell
    }
}

extension ChineseCharacterDictionaryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 { return 10 * 2 + 80 }
        return UITableView.automaticDimension
    }
}
