//
//  JDWebViewController.swift
//  DailyProject-Swift
//
//  Created by wudan on 2021/10/19.
//

import UIKit
import WebKit
import ProgressHUD

class JDWebViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var upLoadButton: UIButton!
    
    var cookieDataSet: Set = Set<HTTPCookie>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Web"
        view.backgroundColor = .white
        webView.uiDelegate = self
        webView.navigationDelegate = self
        upLoadButton.isHidden = true
        webView.loadUrl(string: "https://m.jd.com")
        upLoadButton.addTarget(self, action: #selector(uploadData(sender:)), for: .touchUpInside)
        upLoadButton.setImage(.init(named: "icon_btn_upload"), for: .normal)
        upLoadButton.setTitle("", for: .normal)
        upLoadButton.imageView?.contentMode = .scaleAspectFit
        upLoadButton.layer.cornerRadius = 30
        upLoadButton.backgroundColor = .systemRed
        
        ProgressHUD.animationType = .circleStrokeSpin
        ProgressHUD.colorHUD = .systemGray
        ProgressHUD.colorAnimation = .systemBlue
        ProgressHUD.colorProgress = .systemBlue
        ProgressHUD.colorStatus = .label
        ProgressHUD.fontStatus = .boldSystemFont(ofSize: 24)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        upLoadButton.snp.makeConstraints { make in
            make.trailing.equalTo(30)
            make.bottom.equalTo(70)
            make.height.width.equalTo(60)
        }
    }
}

@objc private extension JDWebViewController {
    func uploadData(sender: Any) {
        var pt_key: String = ""
        var pt_pin: String = ""
        var token: String = ""
        cookieDataSet.forEach { httpCookie in
            if (httpCookie.name == "pt_key") {
                pt_key = httpCookie.value
            }
            
            if (httpCookie.name == "pt_pin") {
                pt_pin = httpCookie.value
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMddHHmm"
            token = NSString.hmac(withSecret: "yi", andString: dateFormatter.string(from: Date()))
            print(dateFormatter.string(from: Date()), token)
        }
        
        
        if pt_key.count > 0 && pt_pin.count > 0 {
            ProgressHUD.show()
            WebAPIManager.request(target: .upload(pt_key, pt_pin, token)) { res in
                ProgressHUD.dismiss()
                if res {
                    let alert = UIAlertController(title: "开心的告诉你", message: "Happy呀，上传成功了~", preferredStyle: .alert)
                    let action = UIAlertAction(title: "okok", style: .default) { action in
                        
                    }
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "不幸的告诉你", message: "卧槽，居然失败了，赶紧检查一下原因~", preferredStyle: .alert)
                    let action = UIAlertAction(title: "走，锤张老师去", style: .default) { action in
                        
                    }
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } else {
            let alert = UIAlertController(title: "温馨提示", message: "没有获取到信息呀，看看是不是没有没登录~", preferredStyle: .alert)
            let action = UIAlertAction(title: "我去检查一下", style: .default) { action in
                
            }
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
}

extension JDWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        let cookieStore: WKHTTPCookieStore = webView.configuration.websiteDataStore.httpCookieStore
        cookieStore.getAllCookies { cookies in
            cookies.forEach { cookie in
                self.cookieDataSet.insert(cookie)
            }
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        upLoadButton.isHidden = false
    }
}

extension JDWebViewController: WKUIDelegate {
    
}

extension WKWebView {
    func loadUrl(string: String) {
        if let encoded = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: encoded) {
            if self.url?.host == url.host {
                self.reload()
            } else {
                load(URLRequest(url: url))
            }
        }
    }
}
