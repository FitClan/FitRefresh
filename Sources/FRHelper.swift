//
//  FRHelper.swift
//  FitRefresh
//
//  Created by Cyrill on 2016/12/28.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

import UIKit

// =======================================
// Common Func
// =======================================

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
public func FRDelay(_ time: TimeInterval, task: @escaping ()->()) -> FRTask? {
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


// =======================================
// DispatchQueueExtension
// =======================================

public extension DispatchQueue {
    
    private static var _onceTracker = [String]()
    
    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     
     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
    /** 单例 */
    public class func once(token: String, block:()->Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        if _onceTracker.contains(token) {
            return
        }
        
        _onceTracker.append(token)
        block()
    }
}


// =======================================
// NSObjectExtension
// ======================================= 

extension NSObject {
    // MARK: runtime
    class func exchangeInstanceMethod(_ method1:Selector, method2:Selector){
        method_exchangeImplementations(class_getInstanceMethod(self, method1)!, class_getInstanceMethod(self, method2)!)
    }
    
    class func exchangeClassMethod(_ method1:Selector, method2:Selector){
        
        method_exchangeImplementations(class_getClassMethod(self, method1)!, class_getClassMethod(self, method2)!)
    }
    
}


// =======================================
// UIScrollViewExtension
// =======================================

extension UIScrollView {
    
    var inset: UIEdgeInsets {
        get {
            if #available(iOS 11.0, *) {
                return self.adjustedContentInset
            }
            return self.contentInset
        }
    }
    
    var offSetY: CGFloat {
        get {
            return self.contentOffset.y
        }
        set {
            self.contentOffset.y = newValue
        }
    }
    
    var offSetX: CGFloat {
        get {
            return self.contentOffset.x
        }
        set {
            self.contentOffset.x = newValue
        }
    }
    
    var insetTop: CGFloat {
        get {
            return self.inset.top
        }
        set {
            var finValue = newValue
            
            if #available(iOS 11.0, *) {
                finValue -= (self.adjustedContentInset.top - self.contentInset.top)
            }
            
            self.contentInset.top = finValue
        }
    }
    
    var insetRight: CGFloat {
        get {
            return self.inset.right
        }
        set {
            var finValue = newValue
            
            if #available(iOS 11.0, *) {
                finValue -= (self.adjustedContentInset.right - self.contentInset.right)
            }
            self.contentInset.right = newValue
        }
    }
    
    var insetLeft: CGFloat {
        get {
            return self.inset.left
        }
        set {
            var finValue = newValue
            
            if #available(iOS 11.0, *) {
                finValue -= (self.adjustedContentInset.left - self.contentInset.left)
            }
            self.contentInset.left = newValue
        }
    }
    var insetBottom: CGFloat {
        get {
            return self.inset.bottom
        }
        set {
            var finValue = newValue
            
            if #available(iOS 11.0, *) {
                finValue -= (self.adjustedContentInset.bottom - self.contentInset.bottom)
            }
            self.contentInset.bottom = newValue
        }
    }
    
    var contentW: CGFloat {
        get {
            return self.contentSize.width
        }
        
        set {
            self.contentSize.width = newValue
        }
    }
    
    var contentH: CGFloat {
        get {
            return self.contentSize.height
        }
        
        set {
            self.contentSize.height = newValue
        }
    }
}


// =======================================
// UIViewExtension
// =======================================

extension UIView {
    
    var x: CGFloat {
        get {
            return self.frame.origin.x
        }
        set {
            self.frame.origin.x = newValue
        }
    }
    
    var y: CGFloat {
        get {
            return self.frame.origin.y
        }
        set {
            self.frame.origin.y = newValue
        }
    }
    
    var width: CGFloat {
        get {
            return self.frame.size.width
        }
        set {
            self.frame.size.width = newValue
        }
    }
    
    var height: CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            self.frame.size.height = newValue
        }
    }
    
    var size: CGSize {
        get {
            return self.frame.size
        }
        set {
            self.frame.size = newValue
        }
    }
    
    var CY_origin: CGPoint {
        get {
            return self.frame.origin
        }
        set {
            self.frame.origin = newValue
        }
    }
    
    var centerX: CGFloat {
        get {
            return self.center.x
        }
        set {
            self.center.x = newValue
        }
    }
    
    var centerY: CGFloat {
        get {
            return self.center.y
        }
        set {
            self.center.y = newValue
        }
    }
}

// =======================================
// Bundle Extension
// =======================================
extension Bundle {
    
    class func fit_refreshBundle() -> Bundle? {
        return Bundle(path: (Bundle(for: FRComponent.self).path(forResource: "FRResources", ofType: "bundle"))!)
    }
    
    class func fit_localizedStringForKey(_ key: String) -> String {
        return self.fit_localizedStringForKey(key, value: nil)
    }
    
    class func fit_localizedStringForKey(_ key: String, value: String?) -> String {
        var varValue = value
        var bundle: Bundle? = nil
        if bundle == nil {
            var language: String = NSLocale.preferredLanguages.first!
            if (language.hasPrefix("zh")) {
                language = "zh-Hans"
            } else {
                language = "en"
            }

            let res_Bundle = self.fit_refreshBundle()
            
            let path = res_Bundle?.path(forResource: language, ofType: "lproj")
            
            bundle = Bundle(path: path!)
        }
        
        varValue = bundle!.localizedString(forKey: key, value: varValue, table: nil)
        return Bundle.main.localizedString(forKey: key, value: varValue, table: nil)
    }
}


// =======================================
// NSDate Extension
// =======================================

extension Date {
    
    /** 转换NSDate->String 精确点 */
    func ConvertStringTime() -> String {
        
        // 1.获得年月日
        let calender = self.currentCalendar()
        
        let unitFlags = NSCalendar.Unit.day
        
        let cmp1:DateComponents = (calender as NSCalendar).components(unitFlags, from: self)
        let cmp2:DateComponents = (calender as NSCalendar).components(unitFlags, from: Date())
        
        let formatter = DateFormatter()
        
        var isToday = false
        if cmp1.day == cmp2.day {
            formatter.dateFormat = " HH:mm"
            isToday = true
        } else if (cmp1.year == cmp2.year) {
            formatter.dateFormat = "MM-dd HH:mm"
        } else {
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
        }
        let time: String = formatter.string(from: self)
        let infoString = isToday ? Bundle.fit_localizedStringForKey("FitRefreshHeaderDateTodayText", value: "今天") : Bundle.fit_localizedStringForKey("FitRefreshHeaderLastTimeText", value: "最后更新")
        
        return infoString + ":" + time
    }
    
    func currentCalendar() -> Calendar {
        // 日历获取在9.0之后的系统使用 current 会抛出异常. 8.0之后使用新的API
        if #available(iOS 8.0, *) {
            return Calendar(identifier: Calendar.Identifier.gregorian)
        } else {
            return Calendar.current
        }
    }
}
