//
//  StateHeader.swift
//  FitRefresh
//
//  Created by Cyrill on 2016/12/28.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

import UIKit

public class FRStateHeader: FRHeader {
    
    // MARK: - private
    /** 每个状态对应的文字 */
    fileprivate var stateTitles: Dictionary<RefreshState, String> = [
        RefreshState.idle : RefreshHeaderStateIdleText,
        RefreshState.refreshing : RefreshHeaderStateRefreshingText,
        RefreshState.pulling : RefreshHeaderStatePullingText
    ]
    
    // MARK: - public
    
    /** 利用这个colsure来决定显示的更新时间 */
    var closureCallLastUpdatedTimeTitle: ((_ lastUpdatedTime:Date) -> String)?
    
    /** 显示上一次刷新时间的label */
    lazy var lastUpdatedTimeLabel: UILabel = {
        [unowned self] in
        let lable = UILabel.FRLabel()
        self.addSubview(lable)
        return lable
        }()
    
    
    /** 显示刷新状态的label */
    lazy var stateLabel: UILabel = {
        [unowned self] in
        let lable = UILabel.FRLabel()
        self.addSubview(lable)
        return lable
        }()
    
    
    /** 设置状态的显示文字 */
    public func setTitle(_ title:String, state: RefreshState) {
        self.stateLabel.text = self.stateTitles[self.state];
    }
    
    /** 文字刷新状态下的显示与隐藏 */
    public var refreshingTitleHidden: Bool = false {
        didSet {
            if oldValue == refreshingTitleHidden { return }
            self.stateLabel.isHidden = refreshingTitleHidden
        }
    }
    
    /** 时间刷新状态下的显示与隐藏*/
    public var refreshingTimeHidden: Bool = false {
        didSet {
            if oldValue == refreshingTimeHidden { return }
            self.lastUpdatedTimeLabel.isHidden = refreshingTimeHidden
            
        }
        
    }
    
    
    // MARK: 重写
    
    override var lastUpdatedateKey: String {
        didSet {
            if let lastUpdatedTimeDate = UserDefaults.standard.object(forKey: lastUpdatedateKey) {
                
                let realLastUpdateTimeDate:Date = lastUpdatedTimeDate as! Date
                
                // 如果有闭包
                if let internalClosure = self.closureCallLastUpdatedTimeTitle {
                    self.lastUpdatedTimeLabel.text = internalClosure(realLastUpdateTimeDate)
                    return
                }
                // 得到精准的时间
                self.lastUpdatedTimeLabel.text = realLastUpdateTimeDate.ConvertStringTime()
                
            }else{
                self.lastUpdatedTimeLabel.text = Bundle.fit_localizedStringForKey("FitRefreshHeaderLastTimeText", value: "最后更新") + ":" + Bundle.fit_localizedStringForKey("FitRefreshHeaderNoneLastDateText", value: "无记录")
                
            }
        }
    }
    
    override var state: RefreshState {
        didSet {
            if state == oldValue { return }
            self.stateLabel.text = self.stateTitles[self.state];
            
            // self.lastUpdatedateKey = self.lastUpdatedateKey.self
            
        }
    }
    
    override func prepare() {
        super.prepare()
        // 初始化文字
        self.setTitle(RefreshHeaderStateIdleText, state: .idle)
        self.setTitle(RefreshHeaderStatePullingText, state: .pulling)
        self.setTitle(RefreshHeaderStateRefreshingText, state: .refreshing)
        
    }
    
    override func placeSubvies() {
        super.placeSubvies()
        // 如果状态隐藏 就直接返回
        if self.stateLabel.isHidden { return }
        
        if self.lastUpdatedTimeLabel.isHidden {
            // 状态
            self.stateLabel.frame = self.bounds
        } else {
            // 状态
            self.stateLabel.frame = CGRect(x: 0, y: 0, width: self.width, height: self.height * 0.5)
            
            // 更新的时间
            self.lastUpdatedTimeLabel.x = 0
            self.lastUpdatedTimeLabel.y = self.stateLabel.height
            self.lastUpdatedTimeLabel.width = self.width
            self.lastUpdatedTimeLabel.height = self.height - self.lastUpdatedTimeLabel.y
            
        }
        
    }

}
