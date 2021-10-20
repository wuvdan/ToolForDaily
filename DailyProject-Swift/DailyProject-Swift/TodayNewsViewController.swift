//
//  TodayNewsViewController.swift
//  DailyProject-Swift
//
//  Created by wudan on 2021/10/13.
//

import UIKit
import JXSegmentedView
import SkeletonView
import SwiftyJSON
import WebKit

fileprivate struct TodayNewsTitleModel {
    var typeName: String
    var typeId: Int
    
    init(_ jsonData: JSON) {
        typeName = jsonData["typeName"].stringValue
        typeId = jsonData["typeId"].intValue
    }
}

fileprivate struct TodayNewsListModel {
    var source: String
    var newsId: String
    var videoList: String
    var digest: String
    var title: String
    var postTime: String
    var imgList: Array<String>
    
    init(_ jsonData: JSON) {
        source = jsonData["source"].stringValue
        newsId = jsonData["newsId"].stringValue
        videoList = jsonData["videoList"].stringValue
        digest = jsonData["digest"].stringValue
        title = jsonData["title"].stringValue
        postTime = jsonData["postTime"].stringValue
        imgList = jsonData["imgList"].arrayValue.map({
            $0.stringValue
        })
    }
}

fileprivate struct TodayNewsDetailImageModel {
    var position: String
    var imgSrc: String
    var size: String
    
    init(_ jsonData: JSON) {
        position = jsonData["position"].stringValue
        imgSrc = jsonData["imgSrc"].stringValue
        size = jsonData["size"].stringValue
    }
}

fileprivate struct TodayNewsDetailModel {
    var title: String
    var content: String
    var source: String
    var ptime: String
    var cover: String
    var docid: String
    var images: Array<TodayNewsDetailImageModel>
    
    init(_ jsonData: JSON) {
        title = jsonData["title"].stringValue
        content = jsonData["content"].stringValue
        source = jsonData["source"].stringValue
        ptime = jsonData["ptime"].stringValue
        cover = jsonData["cover"].stringValue
        docid = jsonData["docid"].stringValue
        images = jsonData["images"].arrayValue.map({
            TodayNewsDetailImageModel($0)
        })
    }
}

class TodayNewsViewController: UIViewController {
    
    lazy var segmentedDataSource: JXSegmentedTitleDataSource = {
        $0.isTitleColorGradientEnabled = true
        return $0
    }(JXSegmentedTitleDataSource())
    
    lazy var segmentedView: JXSegmentedView = {
        $0.delegate = self
        let indicator = JXSegmentedIndicatorLineView()
        indicator.indicatorWidth = 20
        $0.indicators = [indicator]
        $0.listContainer = listContainerView
        view.addSubview($0)
        return $0
    }(JXSegmentedView())
    
    fileprivate var titleItems: Array<TodayNewsTitleModel> = []
    
    lazy var listContainerView: JXSegmentedListContainerView = {
        view.addSubview($0)
        return $0
    }(JXSegmentedListContainerView(dataSource: self, type: .collectionView))

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        APIManager.request(target: .newsType) { [weak self] res in
            guard let weakself = self else { return}
            DispatchQueue.main.async {
                if res.code == 1 {
                    for model in JSON(res.data.arrayValue).arrayValue {
                        print(TodayNewsTitleModel(model))
                        weakself.titleItems.append(TodayNewsTitleModel(model))
                    }
                    weakself.segmentedDataSource.titles = weakself.titleItems.map({ $0.typeName })
                    weakself.segmentedView.dataSource = weakself.segmentedDataSource
                    weakself.segmentedView.reloadData()
                } else {
                    
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        segmentedView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(88)
            make.height.equalTo(44)
        }
        
        listContainerView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(segmentedView.snp.bottom)
        }
    }
}

extension TodayNewsViewController: JXSegmentedViewDelegate {
    //点击选中或者滚动选中都会调用该方法。适用于只关心选中事件，而不关心具体是点击还是滚动选中的情况。
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {}
    // 点击选中的情况才会调用该方法
    func segmentedView(_ segmentedView: JXSegmentedView, didClickSelectedItemAt index: Int) {}
    // 滚动选中的情况才会调用该方法
    func segmentedView(_ segmentedView: JXSegmentedView, didScrollSelectedItemAt index: Int) {}
    // 正在滚动中的回调
    func segmentedView(_ segmentedView: JXSegmentedView, scrollingFrom leftIndex: Int, to rightIndex: Int, percent: CGFloat) {}
}

extension TodayNewsViewController: JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        segmentedDataSource.titles.count
    }
    
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        let v = TodayNewsViewListController()
        v.typeId = titleItems[index].typeId
        return v
    }
}


class TodayNewsViewListController: UIViewController {
    /// 页面分类 id
    var typeId: Int?
    
    lazy var tableView: UITableView = {
        $0.delegate = self
        $0.dataSource = self
        $0.register(TodayNewsViewListTableViewCell.self, forCellReuseIdentifier: "TodayNewsViewListTableViewCell")
        $0.rowHeight = 90
        $0.separatorStyle = .none
        view.addSubview($0)
        return $0
    }(UITableView(frame: .zero, style: .plain))
    
    fileprivate var listModels = Array<TodayNewsListModel>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        if let typeId = typeId {
            APIManager.request(target: .newsList(typeId, 1)) { [weak self] res in
                guard let weakself = self else { return}
                DispatchQueue.main.async {
                    if res.code == 1 {
                        for model in JSON(res.data.arrayValue).arrayValue {
                            print(TodayNewsListModel(model))
                            weakself.listModels.append(TodayNewsListModel(model))
                        }
                        weakself.tableView.reloadData()
                    } else {
                        
                    }
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension TodayNewsViewListController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        listModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = listModels[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodayNewsViewListTableViewCell", for: indexPath) as! TodayNewsViewListTableViewCell
        cell.coverImageView.kf.setImage(with: URL(string:model.imgList.first ?? ""), placeholder: nil, options:  []) { res in }
        cell.contentLabel.text = model.title
        cell.sourceLabel.text = model.source
        cell.timeLabel.text = model.postTime
        return cell
    }
}

extension TodayNewsViewListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = TodayNewsViewListDetailViewControlller()
        vc.newId = listModels[indexPath.row].newsId
        navigationController?.show(vc, sender: nil)
    }
}

extension TodayNewsViewListController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        self.view
    }
}

class TodayNewsViewListDetailViewControlller: UIViewController {
    
    var newId: String?
    lazy var webView: WKWebView = {
        view.addSubview($0)
        return $0
    }(WKWebView(frame: .zero))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        if let newId = newId {
            APIManager.request(target: .newsDetail(newId)) { [weak self] res in
                guard let weakself = self else { return}
                DispatchQueue.main.async {
                    if res.code == 1 {
                        var model = TodayNewsDetailModel(res.data)
                        for imageModel in model.images {
                            model.content = model.content.replacingOccurrences(of: imageModel.position, with: "<img src='\(imageModel.imgSrc)'>")
                        }
                        weakself.webView.loadHTMLString(model.content, baseURL: nil)
                        weakself.title = model.title
                    } else {
                        
                    }
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}


class TodayNewsViewListTableViewCell: UITableViewCell {
    
    enum TodayNewsViewListType {
        case left
        case right
    }
    
    lazy var backView: UIView = {
        $0.backgroundColor = .white
        contentView.addSubview($0)
        return $0
    }(UIView())
    
    /// 封面
    lazy var coverImageView: UIImageView = {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        backView.addSubview($0)
        return $0
    }(UIImageView())
    
    /// 内容
    lazy var contentLabel: UILabel = {
        $0.textColor = .darkGray
        $0.numberOfLines = 3
        $0.font = .systemFont(ofSize: 15)
        backView.addSubview($0)
        return $0
    }(UILabel())
    
    /// 发布时间
    lazy var timeLabel: UILabel = {
        $0.textColor = .lightGray
        $0.numberOfLines = 0
        $0.font = .systemFont(ofSize: 12)
        backView.addSubview($0)
        return $0
    }(UILabel())
    
    /// 来源
    lazy var sourceLabel: UILabel = {
        $0.textColor = .lightGray
        $0.numberOfLines = 0
        $0.font = .systemFont(ofSize: 12)
        contentView.addSubview($0)
        return $0
    }(UILabel())
    
    var listType: TodayNewsViewListType = .left
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(5)
            make.bottom.equalTo(-5)
        }
        
        switch listType {
        case .left:
            coverImageView.snp.makeConstraints { make in
                make.leading.top.bottom.equalToSuperview()
                make.width.equalTo(coverImageView.snp.height)
            }
            
            contentLabel.snp.makeConstraints { make in
                make.leading.equalTo(coverImageView.snp.trailing).offset(10)
                make.trailing.equalTo(-10)
                make.top.equalToSuperview()
            }
            
            timeLabel.snp.makeConstraints { make in
                make.trailing.equalTo(-10)
                make.bottom.equalTo(-5)
            }
            
            sourceLabel.snp.makeConstraints { make in
                make.leading.equalTo(coverImageView.snp.trailing).offset(10)
                make.bottom.equalTo(-5)
            }
        case .right:
            coverImageView.snp.makeConstraints { make in
                make.trailing.top.bottom.equalToSuperview()
                make.width.equalTo(coverImageView.snp.height)
            }
            
            contentLabel.snp.makeConstraints { make in
                make.trailing.equalTo(coverImageView.snp.leading).offset(-10)
                make.leading.equalTo(10)
                make.top.equalToSuperview()
            }
            
            timeLabel.snp.makeConstraints { make in
                make.trailing.equalTo(coverImageView.snp.leading).offset(-10)
                make.bottom.equalTo(-5)
            }
            
            sourceLabel.snp.makeConstraints { make in
                make.leading.equalTo(10)
                make.bottom.equalTo(-5)
            }
        }
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

