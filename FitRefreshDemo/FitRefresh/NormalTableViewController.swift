//
//  NormalTableViewController.swift
//  FitRefresh
//
//  Created by Cyrill on 2017/4/28.
//  Copyright © 2017年 Cyrill. All rights reserved.
//

import UIKit

class NormalTableViewController: UITableViewController {

    var dataArray: Array<String> = []
    
    // FRNormalCellID
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // target
        self.tableView.fr_headerView = FRNormalHeader(target: self, action: #selector(NormalTableViewController.upPullLoadData))
        self.tableView.fr_headerView?.beginRefreshing()
        
        
//        self.tableView.fr_footerView = FRAutoNormalFooter(target: self, action: #selector(NormalTableViewController.downPullLoadData))
        
        // 闭包方法
        self.tableView.fr_footerView = FRAutoNormalFooter(ComponentRefreshingClosure: { 
            self.downPullLoadData()
        })
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        dataArray.removeAll()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.tableView.fr_footerView?.isHidden = (dataArray.count == 0)
        return dataArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FRNormalCellID", for: indexPath)
        
        cell.textLabel?.text = dataArray[indexPath.row]
        
        return cell
    }
    
    func upPullLoadData() {
        
        //延迟执行 模拟网络延迟，实际开发中去掉
        FRDelay(2) {
            
            for i in 1..<15{
                self.dataArray.append("数据 - \(i + self.dataArray.count)")
            }
            
            self.tableView.reloadData()
            
            self.tableView.fr_footerView?.endRefreshing()
            self.tableView.fr_headerView?.endRefreshing()
            
        }
        
    }
    
    func downPullLoadData() {
        
        //延迟执行 模拟网络延迟，实际开发中去掉
        FRDelay(2) {
            
            for i in 1..<15{
                self.dataArray.append("数据 - \(i + self.dataArray.count)")
            }
            
            self.tableView.reloadData()
            
            self.tableView.fr_footerView?.endRefreshing()
        }
    }
}
