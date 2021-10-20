//
//  ToDoListViewController.swift
//  DailyProject-Swift
//
//  Created by wudan on 2021/10/14.
//

import UIKit

class DAlerViewManager {
    static let manager = DAlerViewManager()
    
    lazy var backView: UIButton = {
        let v = UIButton()
        v.frame = UIScreen.main.bounds
        v.backgroundColor = UIColor(white: 0, alpha: 0.0)
        return v
    }()
    
    func show(_ view: UIView, _ inView: UIView?) {
        _show(view, inView)
    }
    
    func _show(_ view: UIView, _ inView: UIView?) {
        var _inView = inView
        if inView == nil {
            if #available(iOS 15, *) {
                _inView = UIApplication.shared.windows.first
//                UIApplication.shared.connectedScenes.first
            } else if #available(iOS 13, *) {
                _inView = UIApplication.shared.windows.first
            } else {
                _inView = UIApplication.shared.keyWindow
            }
        }
        backView.addSubview(view)
        _inView?.addSubview(backView)
        view.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: 300)
        UIView.animate(withDuration: 0.3) {
            self.backView.backgroundColor = UIColor(white: 0, alpha: 0.3)
            view.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 300, width: UIScreen.main.bounds.width, height: 300)
        }
    }
    
    func hiden() {
        
    }
}

class ToDoListViewEditorView: UIView {
    convenience init() {
        self.init()
        backgroundColor = .white
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ToDoListViewController: UIViewController {

    lazy var categroySegment: UISegmentedControl = {
        let t = UISegmentedControl(items: ["今天", "计划", "全部"])
        t.selectedSegmentIndex = 0
        view.addSubview(t)
        return t
    }()
    
    lazy var tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        t.delegate = self
        t.dataSource = self
        t.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        view.addSubview(t)
        return t
    }()
    
    lazy var addButton: UIButton = {
        let t = UIButton()
        t.setTitle("add", for: .normal)
        t.setTitleColor(.systemBlue, for: .normal)
        t.layer.cornerRadius = 30
        t.backgroundColor = .white
        t.addTarget(self, action: #selector(didTappedAddButton(sender:)), for: .touchUpInside)
        view.addSubview(t)
        return t
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        categroySegment.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(30)
            make.top.equalTo(88)
        }
        
        tableView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(categroySegment.snp.bottom)
        }
        
        addButton.snp.makeConstraints { make in
            make.trailing.equalTo(-20)
            make.bottom.equalTo(-50)
            make.width.height.equalTo(60)
        }
    }
}

@objc extension ToDoListViewController {
    /// 点击添加按钮
    func didTappedAddButton(sender: Any) {
        DAlerViewManager.manager.show(ToDoListViewEditorView(), nil)
    }
}

extension ToDoListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        return cell
    }
}

extension ToDoListViewController: UITableViewDelegate {
    
}
