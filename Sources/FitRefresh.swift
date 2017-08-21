//
//  FitRefresh.swift
//  FitRefresh
//
//  Created by Cyrill on 2017/8/21.
//  Copyright © 2017年 Cyrill. All rights reserved.
//

import Foundation

import UIKit
public typealias ScrollView = UIScrollView
typealias TableView = UITableView
typealias CollectionView = UICollectionView

public final class FitRefresh<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

/**
 A type that has FitRefresh extensions.
 */
public protocol FitRefreshCompatible {
    associatedtype CompatibleType
    var fr: CompatibleType { get }
}

public extension FitRefreshCompatible {
    public var fr: FitRefresh<Self> {
        get { return FitRefresh(self) }
    }
}

extension ScrollView: FitRefreshCompatible { }
