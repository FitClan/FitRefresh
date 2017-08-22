//
//  ScrollViewExtension-FitRefresh
//  FitRefresh
//
//  Created by Cyrill on 2016/12/28.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

import UIKit

private var RefreshHeaderKey: Void?
private var RefreshFooterKey: Void?

private var RefreshReloadDataClosureKey:Void?

typealias ClosureParamCountType = (Int)->Void

public class ReloadDataClosureInClass {
    var reloadDataClosure: ClosureParamCountType = { (Int)->Void in }
}

// MARK: 1.3
// ============================================================
// Version: 1.3 
// Description: 替换成 fr. 的调用方式
// ============================================================
extension FitRefresh where Base: ScrollView {
    var reloadDataClosureClass:ReloadDataClosureInClass {
        set{
            
            base.willChangeValue(forKey: "reloadDataClosure")
            //因为闭包不属于class 所以不合适 AnyObject
            objc_setAssociatedObject(base, &RefreshReloadDataClosureKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            base.didChangeValue(forKey: "reloadDataClosure")
        }
        get{
            if let realClosure = objc_getAssociatedObject(base, &RefreshReloadDataClosureKey) {
                return realClosure as! ReloadDataClosureInClass
            }
            return ReloadDataClosureInClass()
        }
        
    }
    
    /** 下拉刷新的控件 */
    var headerView: FRHeader? {
        
        set {
            if headerView == newValue { return }
            
            headerView?.removeFromSuperview()
            objc_setAssociatedObject(base,&RefreshHeaderKey, newValue , objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
            
            if let newHeaderView = newValue {
                base.addSubview(newHeaderView)
            }
        }
        get {
            return objc_getAssociatedObject(base, &RefreshHeaderKey) as? FRHeader
        }
    }
    
    
    
    /** 上拉刷新的控件 */
    var footerView: FRFooter? {
        
        set{
            if footerView == newValue { return }
            footerView?.removeFromSuperview()
            objc_setAssociatedObject(base, &RefreshFooterKey, newValue , objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
            
            if let newFooterView = newValue {
                base.addSubview(newFooterView)
            }
        }
        get{
            return objc_getAssociatedObject(base, &RefreshFooterKey) as? FRFooter
        }
    }
    
    fileprivate var totalDataCount:Int {
        
        get{
            var totalCount:Int = 0
            if base.isKind(of: UITableView.self){
                let tableView = base as! UITableView
                for section in 0..<tableView.numberOfSections {
                    
                    
                    totalCount += tableView.numberOfRows(inSection: section)
                }
                
            } else if base.isKind(of: UICollectionView.self) {
                let collectionView = base as! UICollectionView
                for section in 0..<collectionView.numberOfSections {
                    
                    totalCount += collectionView.numberOfItems(inSection: section)
                }
            }
            return totalCount
            
        }
    }
    
    func executeReloadDataClosure() {
        reloadDataClosureClass.reloadDataClosure(totalDataCount)
    }
}

// 用于加强一个引用
var RetainClosureClass = ReloadDataClosureInClass()

public extension UIScrollView {
    // =================
    // MARK: 1.2 version
    // =================
    
    /** reloadDataClosure */
    @available(*, deprecated, message: "Extensions directly on scroll Views are deprecated. Use like `scrollView.fr.reloadDataClosureClass` instead.", renamed: "fr.reloadDataClosureClass")
    var reloadDataClosureClass:ReloadDataClosureInClass {
        set{
            
            self.willChangeValue(forKey: "reloadDataClosure")
            //因为闭包不属于class 所以不合适 AnyObject
            objc_setAssociatedObject(self, &RefreshReloadDataClosureKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            self.didChangeValue(forKey: "reloadDataClosure")
        }
        get{
            if let realClosure = objc_getAssociatedObject(self, &RefreshReloadDataClosureKey) {
                return realClosure as! ReloadDataClosureInClass
            }
            return ReloadDataClosureInClass()
        }
        
    }
        
    /** 下拉刷新的控件 */
    @available(*, deprecated, message: "Extensions directly on scroll Views are deprecated. Use like `scrollView.fr.headerView` instead.", renamed: "fr.headerView")
    var fr_headerView: FRHeader? {
        
        set {
            if self.fr_headerView == newValue { return }
            
            self.fr_headerView?.removeFromSuperview()
            objc_setAssociatedObject(self,&RefreshHeaderKey, newValue , objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
            
            if let newHeaderView = newValue {
                self.addSubview(newHeaderView)
            }
        }
        get {
            return objc_getAssociatedObject(self, &RefreshHeaderKey) as? FRHeader
        }
    }
    
    
    
    /** 上拉刷新的控件 */
    @available(*, deprecated, message: "Extensions directly on scroll Views are deprecated. Use like `scrollView.fr.footerView` instead.", renamed: "fr.footerView")
    var fr_footerView: FRFooter? {
        
        set{
            if self.fr_footerView == newValue { return }
            self.fr_footerView?.removeFromSuperview()
            objc_setAssociatedObject(self, &RefreshFooterKey, newValue , objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
            
            if let newFooterView = newValue {
                self.addSubview(newFooterView)
            }
        }
        get{
            return objc_getAssociatedObject(self, &RefreshFooterKey) as? FRFooter
        }
    }
    
    
    fileprivate var totalDataCount:Int {
        
        get{
            var totalCount:Int = 0
            if self.isKind(of: UITableView.self){
                let tableView = self as! UITableView
                for section in 0..<tableView.numberOfSections {
                    
                    
                    totalCount += tableView.numberOfRows(inSection: section)
                }
                
            } else if self.isKind(of: UICollectionView.self) {
                let collectionView = self as! UICollectionView
                for section in 0..<collectionView.numberOfSections {
                    
                    totalCount += collectionView.numberOfItems(inSection: section)
                }
            }
            return totalCount
            
        }
    }
    
    @available(*, deprecated, message: "Extensions directly on scroll Views are deprecated. Use like `scrollView.fr.executeReloadDataClosure` instead.", renamed: "fr.executeReloadDataClosure")
    func executeReloadDataClosure() {
        self.reloadDataClosureClass.reloadDataClosure(self.totalDataCount)
    }
    
}

extension UITableView {
    // 这里不推荐 initialize 有警告。正在想替代方法
    open override class func initialize() {
        if self != UITableView.self { return }
        
        DispatchQueue.once(token: "ex") { 
            self.exchangeInstanceMethod(#selector(UITableView.reloadData), method2: #selector(UITableView.frReloadData))
        }
    }
    public func frReloadData() {
        // 因为交换了方法，所以这里其实是执行的系统自己的 reloadData 方法
        
        self.frReloadData()
        
        self.fr.executeReloadDataClosure()
    }
}


