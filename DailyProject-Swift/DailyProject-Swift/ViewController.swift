//
//  ViewController.swift
//  DailyProject-Swift
//
//  Created by wudan on 2021/10/11.
//
/**
    1. 待做事情列表
    2. 随记
    3. 放下手机页面展示
    4. 设定计划
    5. 计时器、倒计时
 */

import UIKit
import SnapKit

class ViewController: UIViewController {
    /// 分组
    fileprivate struct ProjectGroup {
        var name: String
        var items: Array<ProjectItem>
    }
    
    /// 分组中数据 item
    fileprivate struct ProjectItem {
        var name: String
        var controller: UIViewController?
    }

    fileprivate lazy var tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .insetGrouped)
        t.delegate = self
        t.dataSource = self
        t.rowHeight = 40
//        t.sectionHeaderTopPadding = 0
        t.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        view.addSubview(t)
        return t
    }()
    
    fileprivate let dataSource: Array<ProjectGroup> = [
        ProjectGroup(name: "文字处理", items: [
                    ProjectItem(name: "每日精美语句", controller: DailyWordRecommendViewController()),
                    ProjectItem(name: "汉字字典", controller: ChineseCharacterDictionaryViewController()),
                    ProjectItem(name: "文本翻译", controller: TranslationViewController()),
                    ProjectItem(name: "简繁转换", controller: nil)
        ]),
        
        ProjectGroup(name: "万年历", items: [
                    ProjectItem(name: "历史上的今天", controller: nil),
                    ProjectItem(name: "日历", controller: nil)
        ]),
        
        ProjectGroup(name: "每日新闻", items: [
                    ProjectItem(name: "每日新闻", controller: TodayNewsViewController())
        ]),
        
        ProjectGroup(name: "其他", items: [
                    ProjectItem(name: "提醒事项", controller:  ToDoListViewController())
        ]),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "DailyProject"
        
        
        
   
        
    }
    
    func getName(_: (String) -> String) -> Void {
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.section].items[indexPath.row].name
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        dataSource[section].name
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let controller = dataSource[indexPath.section].items[indexPath.row].controller else { return }
        navigationController?.show(controller, sender: nil)
    }
}
