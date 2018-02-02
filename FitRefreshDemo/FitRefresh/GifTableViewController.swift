//
//  GifTableViewController.swift
//  FitRefresh
//
//  Created by Cyrill on 2017/4/28.
//  Copyright © 2017年 Cyrill. All rights reserved.
//

import UIKit

class GifTableViewController: UITableViewController {

    var tmpCount = 0
    var task: FRTask?
    
    var dataArray: Array<String> = []
    
    // FRGifCellID
    // apply_suc_1
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var images = [UIImage]()
        
        for i in 1...20 {
            let image = UIImage(named: String(format: "type_big_%zd", i))
            images.append(image!)
        }
        

        let headerView = FRGifHeader(target: self, action: #selector(GifTableViewController.upPullLoadData))
        headerView.setImages(images, duration: 2.0, state: RefreshState.idle)
        headerView.setImages(images, duration: 2.0, state: RefreshState.refreshing)
        // 隐藏刷新状态栏
        headerView.isRefreshingTitleHidden = true
        // 隐藏刷新时间状态
        headerView.isRefreshingTimeHidden = true
        // 根据上拉比例设置透明度
        headerView.isAutomaticallyChangeAlpha = true

        self.tableView.fr.headerView = headerView
        self.tableView.fr.headerView?.beginRefreshing()
        
        let footerView = FRAutoGifFooter(target: self, action: #selector(GifTableViewController.downPullLoadData))
        footerView.setImages(images, duration: 2.0, state: RefreshState.idle)
        footerView.setImages(images, duration: 2.0, state: RefreshState.refreshing)
        footerView.isRefreshingTitleHidden = true
        self.tableView.fr.footerView = footerView
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        FRCancel(task)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FRGifCellID", for: indexPath)

        cell.textLabel?.text = dataArray[indexPath.row]

        return cell
    }
    
    @objc func downPullLoadData() {
        // 延迟执行 模拟网络延迟，实际开发中去掉
        task = FRDelay(2) {
            
            for _ in 1...15{
                self.tmpCount += 1
                self.dataArray.append("数据 - \(self.tmpCount)")
            }
            
            self.tableView.reloadData()
            if self.tmpCount == 30 {
                self.tableView.fr.footerView?.endRefreshingWithNoMoreData()
            } else {
                self.tableView.fr.footerView?.endRefreshing()
            }
        }
    }
    
    @objc func upPullLoadData() {
        // 延迟执行 模拟网络延迟，实际开发中去掉
        task = FRDelay(2) {
            self.tmpCount = 0
            self.dataArray.removeAll()
            for _ in 1...15{
                self.tmpCount += 1
                self.dataArray.append("数据 - \(self.tmpCount)")
            }
            
            self.tableView.reloadData()

            self.tableView.fr.headerView?.endRefreshing()
            self.tableView.fr.footerView?.resetNoMoreData()
        }
    }
    
}
