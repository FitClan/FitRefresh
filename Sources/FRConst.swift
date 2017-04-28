//
//  FRConst.swift
//  FitRefresh
//
//  Created by Cyrill on 2016/12/30.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

import UIKit

//文字颜色
let RefreshLabelTextColor = FRColor(r: 100, g: 100, b: 100)

//字体大小
let RefreshLabelFont = UIFont.boldSystemFont(ofSize: 13)

/** 头部高度 */
let RefreshHeaderHeight: CGFloat = 64
/** 尾部高度 */
let RefreshFooterHeight: CGFloat = 44

/** gifView 偏差 */
let RefreshGifViewWidthDeviation: CGFloat = 99

/** footer 菊花 偏差 */
let RefreshFooterActivityViewDeviation: CGFloat = 100

/** 开始的动画时间 */
let RefreshFastAnimationDuration = 0.25
/** 慢的动画时间 */
let RefreshSlowAnimationDuration = 0.4

/** 更新的时间 */
let RefreshHeaderLastUpdatedTimeKey = "FitRefreshHeaderLastUpdatedTimeKey"
/** 也就是上拉下拉的多少*/
let RefreshKeyPathContentOffset = "contentOffset"
/** 内容的size */
let RefreshKeyPathContentSize = "contentSize"
/** 内边距 */
let RefreshKeyPathContentInset = "contentInset"
/** 手势状态 */
let RefreshKeyPathPanKeyPathState = "state"

let RefreshHeaderStateIdleText = "下拉可以刷新"
let RefreshHeaderStatePullingText = "松开立即刷新"
let RefreshHeaderStateRefreshingText = "正在刷新数据中..."


let RefreshFooterStateIdleText = "点击加载更多"
let RefreshFooterStateRefreshingText = "正在加载更多的数据..."
let RefreshFooterStateNoMoreDataText = "已经全部加载完毕"

/** 图片路径 */
let FRIconSrcPath:String = "Frameworks/FitRefresh.framework/FRResources.bundle/fr_down.png"
let FRIconLocalPath:String = "FRResources.bundle/fr_down.png"



