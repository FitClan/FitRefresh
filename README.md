# FitRrefesh
<p align="left">
<img src="https://github.com/cywd/FitRrefesh/blob/master/Resources/logo.png" alt="FitRefresh" title="FitRefresh" width="100"/>
</p>

## 描述

Swift 3+ 的 下拉刷新

## 使用

### Version 1.3

```swift
// header
// first way
self.tableView.fr.headerView = FRNormalHeader(target: self, action: #selector(NormalTableViewController.upPullLoadData))
self.tableView.fr.headerView?.beginRefreshing()
// second way
self.tableView.fr.headerView = FRNormalHeader(ComponentRefreshingClosure: { 
            self.upPullLoadData()
        })
self.tableView.fr.headerView?.beginRefreshing()

// footer
// first way
self.tableView.fr.footerView = FRAutoNormalFooter(target: self, action: #selector(NormalTableViewController.downPullLoadData))
// second way
self.tableView.fr.footerView = FRAutoNormalFooter(ComponentRefreshingClosure: {
            self.downPullLoadData()
        })
```

### Version 1.2 

```swift
// header
// first way
self.tableView.fr_headerView = FRNormalHeader(target: self, action: #selector(NormalTableViewController.upPullLoadData))
self.tableView.fr_headerView?.beginRefreshing()
// second way
self.tableView.fr_headerView = FRNormalHeader(ComponentRefreshingClosure: { 
            self.upPullLoadData()
        })
self.tableView.fr_headerView?.beginRefreshing()

// footer
// first way
self.tableView.fr_footerView = FRAutoNormalFooter(target: self, action: #selector(NormalTableViewController.downPullLoadData))
// second way
self.tableView.fr_footerView = FRAutoNormalFooter(ComponentRefreshingClosure: {
            self.downPullLoadData()
        })
```







