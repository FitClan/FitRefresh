//
//  Component.swift
//  FitRefresh
//
//  Created by Cyrill on 2016/12/28.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

import UIKit

/** 刷新状态 */
public enum RefreshState: Int{
    /**普通闲置状态 */
    case idle = 1
    /** 松开可以进行刷新状态 */
    case pulling = 2
    /**正在刷新中的状态 */
    case refreshing = 3
    /** 即将刷新的状态 */
    case willRefresh = 4
    /**没有数据需要加载 */
    case noMoreData = 5
}

/** 闭包的类型 ()->() */
public typealias ComponentRefreshingClosure = ()->()

/** 抽象类，不直接使用，用于继承后，重写*/
public class Component: UIView {
    
    // MARK: - 公共接口
    // MARK: 给外界访问
    // 1.字体颜色
    public var textColor: UIColor?
    
    // 2.字体大小
    public var font: UIFont?
    
    // 3.刷新的target
    fileprivate weak var refreshingTarget:AnyObject!
    
    // 4.执行的方法
    fileprivate var refreshingAction: Selector = NSSelectorFromString("")
    
    // 5.真正刷新 回调
    var refreshingClosure: ComponentRefreshingClosure = {}
    
    /** 拉拽的百分比 */
    public var pullingPercent:CGFloat = 1 {
        didSet {
            if self.state == RefreshState.refreshing { return }
            if self.automaticallyChangeAlpha == true {
                self.alpha = pullingPercent
            }
        }
    }
    
    /** 根据拖拽比例自动切换透明度 */
    public var automaticallyChangeAlpha:Bool = false {
        didSet {
            if self.state == RefreshState.refreshing { return }
            if automaticallyChangeAlpha == true {
                self.alpha = self.pullingPercent
            } else {
                self.alpha = 1.0
            }
        }
    }
    
    /** 8.刷新状态，交给子类重写 */
    var state = RefreshState.idle
    
    /** 是否在刷新 */
    public var isRefreshing:Bool {
        get {
            return self.state == .refreshing || self.state == .willRefresh;
        }
    }
    
    // MARK 方法
    // 提供方便，有提示
    func addCallBack(_ block: @escaping ComponentRefreshingClosure) {
        self.refreshingClosure = block
    }
    
    // MARK: 遍历构造方法
    
    /** 闭包回调 */
    public convenience
    init(ComponentRefreshingClosure: @escaping ComponentRefreshingClosure) {
        self.init()
        self.refreshingClosure = ComponentRefreshingClosure
    }
    
    /** target action 回调 [推荐] */
    public convenience
    init(target: AnyObject, action: Selector) {
        self.init()
        self.setRefreshingTarget(target, action: action)
    }
    
    /* 1. 设置 回调方法 */
    func setRefreshingTarget(_ target: AnyObject, action: Selector) {
        self.refreshingTarget = target
        self.refreshingAction = action
        
    }
    
    // MARK: 提供给子类重写
    
    /** 开始刷新,进入刷新状态 */
    public func beginRefreshing() {
        UIView.animate(withDuration: RefreshSlowAnimationDuration, animations: { () -> Void in
            self.alpha = 1.0
        })
        
        self.pullingPercent = 1.0
        
        // 在刷新
        if let _ =  self.window {
            self.state = .refreshing
        }else{
            self.state = RefreshState.willRefresh
            // 刷新(预防从另一个控制器回到这个控制器的情况，回来要重新刷新一下)
            self.setNeedsDisplay()
        }
    }
    
    /** 结束刷新 */
    public func endRefreshing() {
        self.state = .idle
    }
    
    
    // MARK: 初始化
    func prepare() {
        // 基本属性 只适应 宽度
        self.autoresizingMask = UIViewAutoresizing.flexibleWidth
        self.backgroundColor = UIColor.clear
    }
    
    /** 6. 摆放子控件 */
    func placeSubvies() {}
    
    /** 7. 当scrollView的contentOffset发生改变的时候调用 */
    func scrollViewContentOffsetDidChange(_ change: [NSKeyValueChangeKey : Any]?) {}
    
    /** 8. 当scrollView的contentSize发生改变的时候调用 */
    func scrollViewContentSizeDidChange(_ change: [NSKeyValueChangeKey : Any]?) {}
    
    /** 9. 当scrollView的拖拽状态发生改变的时候调用 */
    func scrollViewPanStateDidChange(_ change: [NSKeyValueChangeKey : Any]?) {}
    
    /** 促发回调 */
    func executeRefreshingCallback() {
        
        DispatchQueue.main.async {
            
            self.refreshingClosure()
            
            //执行方法
            if let realTager = self.refreshingTarget {
                if realTager.responds(to: self.refreshingAction) == true {
                    
                    let timer = Timer.scheduledTimer(timeInterval: 0, target: self.refreshingTarget, selector: self.refreshingAction, userInfo: nil, repeats: false)
                    RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
                }
            }
        }
    }
    
    // MARK: - 私有
    
    /** 记录scrollView刚开始的inset */
    var scrollViewOriginalInset: UIEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
    /** 父控件 */
    weak var scrollView: UIScrollView!
    
    fileprivate var panGes: UIPanGestureRecognizer!
    
    // 从写初始化方法
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        prepare()
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // 重写父类方法 这个view 会添加到 ScrollView 上去
    override public func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        // 1.旧的父控件 移除监听
        self.removeObservers()
        
        // 2.添加监听
        if let tmpNewSuperview = newSuperview {
            
            // 2.1设置宽度
            self.width = tmpNewSuperview.width
            
            // 2.2 设置位置
            self.x = 0
            
            // 2.3记录UIScrollView
            self.scrollView = tmpNewSuperview as! UIScrollView
            
            // 2.4 设置用于支持 垂直下拉有弹簧的效果
            self.scrollView.alwaysBounceVertical = true;
            
            // 2.5 记录UIScrollView最开始的contentInset
            self.scrollViewOriginalInset = self.scrollView.contentInset;
            
            // 2.6 添加监听
            self.addObservers()
        }
    }
    
    // MARK:  添加监听
    fileprivate func addObservers() {
        
        let options:NSKeyValueObservingOptions = NSKeyValueObservingOptions.new
        
        self.scrollView.addObserver(self , forKeyPath: RefreshKeyPathContentSize, options: options, context: nil)
        
        self.scrollView.addObserver(self , forKeyPath: RefreshKeyPathContentOffset, options: options, context: nil)
        
        self.panGes = self.scrollView.panGestureRecognizer
        
        self.panGes.addObserver(self , forKeyPath: RefreshKeyPathPanKeyPathState, options: options, context: nil)
        
    }
    
    fileprivate func removeObservers() {
        
        if let realSuperview = self.superview {
            realSuperview.removeObserver(self, forKeyPath: RefreshKeyPathContentOffset)
            // TODO: 写到这里，不知道什么原因，但是可以肯定没有销毁
            realSuperview.removeObserver(self, forKeyPath: RefreshKeyPathContentSize)
        }
        if let realPan = self.panGes {
            realPan.removeObserver(self, forKeyPath: RefreshKeyPathPanKeyPathState)
        }
        self.panGes = nil
    }

    // MARK: drawRect
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if self.state == RefreshState.willRefresh {
            // 预防view还没显示出来就调用了beginRefreshing
            self.state = .refreshing
        }
    }
    
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        self.placeSubvies()
    }
    
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        // 需要这种情况就直接返回
        if !self.isUserInteractionEnabled { return }
        
        if keyPath == RefreshKeyPathContentSize {
            self.scrollViewContentSizeDidChange(change)
        }
        
        if self.isHidden {return}
        
        if keyPath == RefreshKeyPathContentOffset {
            self.scrollViewContentOffsetDidChange(change)
        } else if keyPath == RefreshKeyPathPanKeyPathState {
            self.scrollViewPanStateDidChange(change)
        }
    }
    
}

extension UILabel {
    class func FRlabel() -> UILabel {
        let FRLable = UILabel()
        FRLable.font = RefreshLabelFont;
        FRLable.textColor = RefreshLabelTextColor;
        FRLable.autoresizingMask = UIViewAutoresizing.flexibleWidth;
        FRLable.textAlignment = NSTextAlignment.center;
        FRLable.backgroundColor = UIColor.clear;
        return FRLable
    }
}



