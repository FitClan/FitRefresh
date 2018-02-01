//
//  AutoStateFooter.swift
//  FitRefresh
//
//  Created by Cyrill on 2016/12/28.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

import UIKit

public class FRAutoStateFooter: FRAutoFooter {
    // MARK: - public
    public var labelLeftInset: CGFloat = 20
    
    /// 显示刷新状态的label
    lazy var stateLabel: UILabel = {
        [unowned self] in
        let label = UILabel.FRLabel()
        self.addSubview(label)
        return label
        }()
    
    /// 隐藏刷新状态的文字
    public var isRefreshingTitleHidden: Bool = false
    
    /// 设置状态的显示文字
    public func setTitle(_ title: String?, state:RefreshState) {
        if let text = title {
            self.stateTitles[self.state] = text
            self.stateLabel.text = self.stateTitles[self.state];
        }
    }
    
    // MARK: - private
    /** 每个状态对应的文字 */
    fileprivate var stateTitles: Dictionary<RefreshState, String> = [
        RefreshState.idle : RefreshFooterStateIdleText,
        RefreshState.refreshing : RefreshFooterStateRefreshingText,
        RefreshState.noMoreData : RefreshFooterStateNoMoreDataText
    ]
    
    override func prepare() {
        super.prepare()
        
        self.stateLabel.text = self.stateTitles[state]
        
        self.stateLabel.isUserInteractionEnabled = true
        self.stateLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FRAutoStateFooter.stateLabelClick)))
    }
    
    @objc func stateLabelClick() {
        if self.state == RefreshState.idle {
            self.beginRefreshing()
        }
    }
    
    override func placeSubvies() {
        super.placeSubvies()
        self.stateLabel.frame = self.bounds
    }
    
    override var state: RefreshState {
        didSet {
            if oldValue == state { return }
            if self.isRefreshingTitleHidden && state == RefreshState.refreshing {
                self.stateLabel.text = nil
            } else {
                self.stateLabel.text = self.stateTitles[state]
            }
        }
    }
}
