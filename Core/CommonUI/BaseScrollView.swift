//
//  BaseScrollView.swift
//  MJKit
//
//  Created by 郭明健 on 2025/10/15.
//

import UIKit
import MJRefresh

public class BaseScrollView: UIScrollView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        //
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.isScrollEnabled = true
        self.contentInsetAdjustmentBehavior = .never
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -
    /// 下拉刷新头部样式（等同于 `MJRefreshHeaderStyle`）
    public typealias HeaderStyle = MJRefreshHeaderStyle
    
    /// 文字/菊花颜色（默认黑色）
    public var loadingColor: UIColor?
    
    /// 是否支持下拉刷新
    public var isCanRefresh: Bool = false {
        didSet {
            setupHeaderRefresh()
        }
    }
    /// 下拉刷新头部样式（默认 `.normal`；`.gif` 只显示动画、无文字）
    public var refreshHeaderStyle: HeaderStyle = .normal {
        didSet {
            setupHeaderRefresh()
        }
    }
    /// 是否支持上拉加载更多
    public var isCanLoadMore: Bool = false {
        didSet {
            setupFooterRefresh()
        }
    }
    
    // MARK: - Block
    public var headerRefreshBlock: (() -> Void)?
    public var footerRefreshBlock: (() -> Void)?
    
    // MARK: -
    private lazy var mjNormalHeader = MJRefreshNormalHeader()
    private lazy var mjGifHeader = MJGifHeader()
    private lazy var mjFooter = MJRefreshBackNormalFooter()
    
    /// 当前使用的刷新头部（跟随 `refreshHeaderStyle`）
    private var currentHeader: MJRefreshHeader {
        return refreshHeaderStyle == .gif ? mjGifHeader : mjNormalHeader
    }
    
    // MARK: -
    public func endRefresh(isHasMoreData: Bool = true) {
        self.mj_header?.endRefreshing()
        if isHasMoreData {
            self.mjFooter.endRefreshing()
        } else {
            self.mjFooter.endRefreshingWithNoMoreData()
        }
    }
    
    private func setupHeaderRefresh() {
        guard isCanRefresh else {
            self.mj_header = nil
            return
        }
        let header = currentHeader
        header.setRefreshingTarget(self, refreshingAction: #selector(mjHeaderRefresh))
        // 文字/菊花颜色（GIF 头部无文字，配置无效）
        if let normalHeader = header as? MJRefreshNormalHeader,
           let loadingColor = loadingColor {
            normalHeader.stateLabel?.textColor = loadingColor
            normalHeader.lastUpdatedTimeLabel?.textColor = loadingColor
            normalHeader.loadingView?.color = loadingColor
            // 隐藏文字
            //normalHeader.stateLabel?.isHidden = true
            //normalHeader.lastUpdatedTimeLabel?.isHidden = true
        }
        self.mj_header = header
    }
    
    private func setupFooterRefresh() {
        if isCanLoadMore {
            // load more
            mjFooter.setRefreshingTarget(self, refreshingAction: #selector(mjFooterRefresh))
            mjFooter.resetNoMoreData()
            // 文字/菊花颜色
            if let loadingColor = loadingColor {
                mjFooter.stateLabel?.textColor = loadingColor
                mjFooter.loadingView?.color = loadingColor
            }
            self.mj_footer = mjFooter
        } else {
            self.mj_footer = nil
        }
    }
    
    // MARK: - actions
    @objc private func mjHeaderRefresh() {
        headerRefreshBlock?()
    }
    
    @objc private func mjFooterRefresh() {
        footerRefreshBlock?()
    }
}
