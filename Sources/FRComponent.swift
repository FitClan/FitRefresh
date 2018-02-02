//
//  FRComponent.swift
//  FitRefresh
//
//  Created by Cyrill on 2016/12/28.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

import UIKit

/// 刷新状态
public enum RefreshState: Int {
    /// 普通闲置状态
    case idle = 1
    /// 松开可以进行刷新状态
    case pulling = 2
    /// 正在刷新中的状态
    case refreshing = 3
    /// 即将刷新的状态
    case willRefresh = 4
    /// 没有数据需要加载
    case noMoreData = 5
}

/// 闭包的类型 ()->()
/// 进入刷新状态的回调
public typealias ComponentRefreshingClosure = ()->()
/// 开始刷新后的回调（进入刷新状态后的回调）
public typealias ComponentbeginRefreshingCompletionBlock = ()->()
/// 结束刷新后的回调
public typealias ComponentEndRefreshingCompletionBlock = ()->()

/// 抽象类，不直接使用，用于继承后，重写
public class FRComponent: UIView {
    
    // MARK: - public
    // MARK: 给外界访问
    // 字体颜色
    public var textColor: UIColor?
    
    // 字体大小
    public var font: UIFont?
    
    // 刷新的target
    fileprivate weak var refreshingTarget: AnyObject!
    
    // 执行的方法
    fileprivate var refreshingAction: Selector = NSSelectorFromString("")
    
    // 真正刷新 回调
    var refreshingClosure: ComponentRefreshingClosure = {}
    
    var beginRefreshingCompletionBlock: ComponentbeginRefreshingCompletionBlock = {}
    var endRefreshingCompletionBlock: ComponentEndRefreshingCompletionBlock = {}

    /// 拉拽的百分比
    public var pullingPercent: CGFloat = 1.0 {
        didSet {
            if self.isRefreshing { return }
            if self.isAutomaticallyChangeAlpha {
                self.alpha = pullingPercent
            }
        }
    }
    
    /// 根据拖拽比例自动切换透明度
    public var isAutomaticallyChangeAlpha: Bool = false {
        didSet {
            if self.isRefreshing { return }
            if isAutomaticallyChangeAlpha {
                self.alpha = self.pullingPercent
            } else {
                self.alpha = 1.0
            }
        }
    }
    
    /// 刷新状态，交给子类重写
    var state = RefreshState.idle {
        didSet {
            DispatchQueue.main.async {
                self.setNeedsLayout()
            }
        }
    }
    
    /// 是否在刷新
    public var isRefreshing: Bool {
        get {
            return self.state == .refreshing || self.state == .willRefresh
        }
    }
    
    // MARK 方法
    // 提供方便，有提示
    func addCallBack(_ block: @escaping ComponentRefreshingClosure) {
        self.refreshingClosure = block
    }
    
    // MARK: 遍历构造方法
    /// 闭包回调
    public convenience
    init(ComponentRefreshingClosure: @escaping ComponentRefreshingClosure) {
        self.init()
        self.refreshingClosure = ComponentRefreshingClosure
    }
    
    /// target action 回调 [推荐]
    public convenience
    init(target: AnyObject, action: Selector) {
        self.init()
        self.setRefreshingTarget(target, action: action)
    }
    
    /// 设置 回调方法
    func setRefreshingTarget(_ target: AnyObject, action: Selector) {
        self.refreshingTarget = target
        self.refreshingAction = action
    }
    
    
    // MARK: 提供给子类重写
    /// 开始刷新,进入刷新状态
    public func beginRefreshing() {
        UIView.animate(withDuration: RefreshFastAnimationDuration, animations: { () -> Void in
            self.alpha = 1.0
        })
        
        self.pullingPercent = 1.0
        
        // 在刷新
        if let _ =  self.window {
            self.state = .refreshing
        } else {
            if self.state != RefreshState.refreshing {
                self.state = RefreshState.willRefresh
                // 刷新(预防从另一个控制器回到这个控制器的情况，回来要重新刷新一下)
                self.setNeedsDisplay()
            }
        }
    }
    
    public func beginRefreshingWithCompletionBlock(completion: @escaping ()->()) {
        self.beginRefreshingCompletionBlock = completion
        self.beginRefreshing()
    }
    
    /// 结束刷新
    public func endRefreshing() {
        DispatchQueue.main.async {
            self.state = .idle
        }
    }
    
    public func endRefreshingWithCompletionBlock(completion: @escaping ()->()) {
        self.endRefreshingCompletionBlock = completion
        self.endRefreshing()
    }
    
    // MARK: 初始化
    func prepare() {
        // 基本属性 只适应 宽度
        self.autoresizingMask = UIViewAutoresizing.flexibleWidth
        self.backgroundColor = UIColor.clear
    }
    
    /// 摆放子控件
    func placeSubvies() {}
    
    /// 当scrollView的contentOffset发生改变的时候调用
    func scrollViewContentOffsetDidChange(_ change: [NSKeyValueChangeKey : Any]?) {}
    /// 当scrollView的contentSize发生改变的时候调用
    func scrollViewContentSizeDidChange(_ change: [NSKeyValueChangeKey : Any]?) {}
    /// 当scrollView的拖拽状态发生改变的时候调用
    func scrollViewPanStateDidChange(_ change: [NSKeyValueChangeKey : Any]?) {}
    
    /// 促发回调
    func executeRefreshingCallback() {
        DispatchQueue.main.async {
            self.refreshingClosure()
            
            // 执行方法
            if let realTaget = self.refreshingTarget {
                if realTaget.responds(to: self.refreshingAction) == true {
                    let timer = Timer.scheduledTimer(timeInterval: 0, target: self.refreshingTarget, selector: self.refreshingAction, userInfo: nil, repeats: false)
                    RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
                }
            }
            self.beginRefreshingCompletionBlock()
        }
    }
    
    // MARK: - private
    /// 记录scrollView刚开始的inset
    var scrollViewOriginalInset: UIEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
    /// 父控件 */
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
        
        // 2.添加监听
        if let tmpNewSuperview = newSuperview {
        
            // 如果不是UIScrollView return
            if !tmpNewSuperview.isKind(of: UIScrollView.self) { return }
            
            // 旧的父控件 移除监听
            self.removeObservers()
            
            // 设置宽度
            self.width = tmpNewSuperview.width
            
            // 设置位置
            self.x = 0
            if let _ = self.scrollView {
                self.x = -self.scrollView.insetLeft
            }
            
            // 记录UIScrollView
            self.scrollView = tmpNewSuperview as! UIScrollView
            
            // 设置用于支持 垂直下拉有弹簧的效果
            self.scrollView.alwaysBounceVertical = true
            
            // 记录UIScrollView最开始的contentInset
            self.scrollViewOriginalInset = self.scrollView.inset
            
            // 添加监听
            self.addObservers()
        }
    }
    
    // MARK:  添加监听
    fileprivate func addObservers() {
        
        let options: NSKeyValueObservingOptions = NSKeyValueObservingOptions.new
        
        self.scrollView.addObserver(self , forKeyPath: RefreshKeyPathContentSize, options: options, context: nil)
        
        self.scrollView.addObserver(self , forKeyPath: RefreshKeyPathContentOffset, options: options, context: nil)
        
        self.panGes = self.scrollView.panGestureRecognizer
        
        self.panGes.addObserver(self, forKeyPath: RefreshKeyPathPanKeyPathState, options: options, context: nil)
        
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
        self.placeSubvies()
        super.layoutSubviews()
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
    class func FRLabel() -> UILabel {
        let FRLabel = UILabel()
        FRLabel.font = RefreshLabelFont
        FRLabel.textColor = RefreshLabelTextColor
        FRLabel.autoresizingMask = UIViewAutoresizing.flexibleWidth
        FRLabel.textAlignment = NSTextAlignment.center
        FRLabel.backgroundColor = UIColor.clear
        return FRLabel
    }
    
    var fr_textWidth: CGFloat {
        var stringWidth: CGFloat = 0
        
        let size = CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT))
        
        if let text = self.text {
            if text.count > 0 {
                stringWidth = text.boundingRect(with: size, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font : self.font], context: nil).size.width
            }
        }
       
        return stringWidth
    }
}
