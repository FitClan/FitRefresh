//
//  Footer.swift
//  FitRefresh
//
//  Created by Cyrill on 2016/12/28.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

import UIKit

open class FRFooter: Component {
    //MARK: 提供外界访问的
    /** 提示没有更多的数据 */
    open func noticeNoMoreData(){ self.state = RefreshState.noMoreData }
    
    /** 重置没有更多的数据（消除没有更多数据的状态） */
    open func resetNoMoreData(){  self.state = RefreshState.idle }
    
    /** 忽略多少scrollView的contentInset的bottom */
    open var ignoredScrollViewContentInsetBottom:CGFloat = 0
    
    /** 自动根据有无数据来显示和隐藏（有数据就显示，没有数据隐藏） */
    open var automaticallyHidden:Bool = true
    
    
    //MARK: 私有的
    
    //重写父类方法
    override func prepare() {
        super.prepare()
        self.height = RefreshFooterHeight
    }
    
    override open func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        if let _ = newSuperview {
            
            //监听scrollView数据的变化
            //由于闭包是Any 所以不能采用关联对象
            let tmpClass = ReloadDataClosureInClass()
            tmpClass.reloadDataClosure = { (totalCount:Int) -> Void in
                
                if self.automaticallyHidden == true {
                    //如果开启了自动隐藏，那就是在检查到总数量为 请求后的加载0 的时候就隐藏
                    self.isHidden = totalCount == 0
                }
            }
            self.scrollView.reloadDataClosureClass = tmpClass
            
        }
    }
}
