//
//  FRHelper.swift
//  FitRefresh
//
//  Created by Cyrill on 2016/12/28.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

import UIKit

/** ===========================================================================================
 Common Func
 ===============================================================================================*/

func FRColor(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
    return FRColor(r: r, g: g, b: b, a: 1.0)
}

func FRColor(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) -> UIColor {
    return UIColor(red: (r / 255.0), green: (g / 255.0), blue: (b / 255.0), alpha: a)
}

// MARK: delay
public typealias FRTask = (_ cancel: Bool) -> Void
/** 延迟执行 */
@discardableResult
func FRDelay(_ time: TimeInterval, task: @escaping ()->()) -> FRTask? {
    func dispatch_later(block: @escaping ()->()) -> Void {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time, execute: block)
    }
    
    var closure: (()->Void)? = task
    var result: FRTask?
    
    let delayedClosure: FRTask = {
        cancel in
        if let realClosure = closure {
            if cancel == false {
                DispatchQueue.main.async(execute: realClosure)
            }
        }
        closure = nil
        result = nil
    }

    result = delayedClosure
    
    dispatch_later { 
        if let delayedClosure = result {
            delayedClosure(false)
        }
    }
    
    return result
}
/** 取消任务 */
public func FRCancel(_ task: FRTask?) {
    task?(true)
}


/** ===========================================================================================
 NSObjectExtension
 ===============================================================================================*/

extension NSObject{
    // MARK: runtime
    class func exchangeInstanceMethod(_ method1:Selector, method2:Selector){
        method_exchangeImplementations(class_getInstanceMethod(self, method1), class_getInstanceMethod(self, method2))
    }
    
    class func exchangeClassMethod(_ method1:Selector, method2:Selector){
        
        method_exchangeImplementations(class_getClassMethod(self, method1), class_getClassMethod(self, method2));
    }
    
    
    // MARK: 执行某个方法
    func doAction(_ action:Selector){
        if self.responds(to: action) == true {
            let timer = Timer.scheduledTimer(timeInterval: 0, target: self, selector:action, userInfo: nil, repeats: false)
            RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
        }
    }
    
}


/** ===========================================================================================
 UIScrollViewExtension
 ===============================================================================================*/

extension UIScrollView {
    
    var offSetY:CGFloat {
        get {
            return self.contentOffset.y
        }
        set {
            self.contentOffset.y = newValue
        }
    }
    
    var offSetX:CGFloat {
        get {
            return self.contentOffset.x
        }
        set {
            self.contentOffset.x = newValue
        }
    }
    
    var insertTop:CGFloat {
        get {
            return self.contentInset.top
        }
        set {
            self.contentInset.top = newValue
        }
    }
    
    var insertRight:CGFloat {
        get {
            return self.contentInset.right
        }
        set {
            self.contentInset.right = newValue
        }
    }
    
    var insertLeft:CGFloat {
        get {
            return self.contentInset.left
        }
        set {
            self.contentInset.left = newValue
        }
    }
    var insertBottom:CGFloat {
        get {
            return self.contentInset.bottom
        }
        set {
            self.contentInset.bottom = newValue
        }
    }
    
    var contentW:CGFloat {
        get{
            return self.contentSize.width
        }
        
        set {
            self.contentSize.width = newValue
        }
    }
    
    var contentH:CGFloat {
        get{
            return self.contentSize.height
        }
        
        set {
            self.contentSize.height = newValue
        }
    }
}


/** ===========================================================================================
 UIViewExtension
 ===============================================================================================*/

extension UIView {
    
    
    var x:CGFloat {
        get {
            return self.frame.origin.x
        }
        set {
            self.frame.origin.x = newValue
        }
    }
    
    var y:CGFloat {
        get {
            return self.frame.origin.y
        }
        set {
            self.frame.origin.y = newValue
        }
    }
    
    var width:CGFloat {
        get {
            return self.frame.size.width
        }
        set {
            self.frame.size.width = newValue
        }
    }
    
    var height:CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            self.frame.size.height = newValue
        }
    }
    
    var size:CGSize {
        get {
            return self.frame.size
        }
        set {
            self.frame.size = newValue
        }
    }
    var CY_origin:CGPoint {
        get {
            return self.frame.origin
        }
        set {
            self.frame.origin = newValue
        }
    }
    
    var centerX:CGFloat {
        get {
            return self.center.x
        }
        set {
            self.center.x = newValue
        }
    }
    
    var centerY:CGFloat {
        get {
            return self.center.y
        }
        set {
            self.center.y = newValue
        }
    }
}


/** ===========================================================================================
 NSDate Extension
 ===============================================================================================*/
extension Date {
    
    /** 转换NSDate->String 精确点 */
    func ConvertStringTime() -> String {
        
        // 1.获得年月日
        let calender = Calendar.current
        
        let unitFlags = NSCalendar.Unit.day
        
        let cmp1:DateComponents = (calender as NSCalendar).components(unitFlags, from: self)
        
        let cmp2:DateComponents = (calender as NSCalendar).components(unitFlags, from: Date())
        
        let formatter = DateFormatter()
        
        if cmp1.day == cmp2.day {
            
            formatter.dateFormat = "今天 HH:mm"
        }else {
            formatter.dateFormat = "MM-dd HH:mm"
        }
        return "最后更新:" + formatter.string(from: self)
    }
}
