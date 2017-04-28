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

// 用于加强一个引用
// var RetainClosureClass = ReloadDataClosureInClass()

public extension UIScrollView {
    /** ===========================================================================================
     1.2 version
     ===============================================================================================*/
    
    
    //MARK: 1.2 version
    
    /** reloadDataClosure */
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
    
    var totalDataCount:Int{
        
        get{
            var totalCount:Int = 0
            if self.isKind(of: UITableView.self){
                let tableView = self as! UITableView
                for section in 0..<tableView.numberOfSections {
                    
                    
                    totalCount += tableView.numberOfRows(inSection: section)
                }
                
            }else if self.isKind(of: UICollectionView.self) {
                let collectionView = self as! UICollectionView
                for section in 0..<collectionView.numberOfSections {
                    
                    totalCount += collectionView.numberOfItems(inSection: section)
                }
            }
            return totalCount
            
        }
    }
    
    func executeReloadDataClosure(){
        self.reloadDataClosureClass.reloadDataClosure(self.totalDataCount)
    }
    
}



