//
//  MJGifHeader.swift
//
//  Created by 郭明健 on 2026/11/25.
//

import UIKit
import MJRefresh

/// 下拉刷新头部样式（`BaseTableView` / `BaseCollectionView` / `BaseScrollView` 通用）
public enum MJRefreshHeaderStyle {
    /// 系统菊花 + 状态文字
    case normal
    /// GIF loading（MJKit 内置 loading_0…loading_59）
    case gif
}

/// GIF loading 下拉刷新头部（基于 MJRefreshGifHeader）
///
/// 图片资源在 `MJKit.xcassets/Refresh_loading` 下，命名 `loading_0` … `loading_59`。
/// 隐藏了状态文字与刷新时间，只保留居中的 GIF 动画。
public class MJGifHeader: MJRefreshGifHeader {
    /// 动画帧数量（loading_0 … loading_59）
    private static let frameCount = 60
    /// 一轮动画时长（秒）
    private static let animationDuration: TimeInterval = 1.5
    
    /// 帧图片只从 Assets 读一次，避免每次刷新都重新解码
    private static let refreshImages: [UIImage] = {
        var images: [UIImage] = []
        for i in 0 ..< frameCount {
            let image = ("loading_" + i.toString()).mj_Image()
            // 缺图时跳过，避免空图占位导致动画闪烁
            if !image.isEmpty {
                images.append(image)
            }
        }
        return images
    }()
    
    public override func prepare() {
        super.prepare()
        // 隐藏状态显示文字
        stateLabel?.isHidden = true
        // 隐藏更新时间文字
        lastUpdatedTimeLabel?.isHidden = true
        
        gifView?.contentMode = .center
        gifView?.clipsToBounds = false
        
        let images = Self.refreshImages
        guard let firstImage = images.first else { return }
        // 静止态：显示首帧；下拉 / 刷新中：播放完整动画
        setImages([firstImage], for: .idle)
        setImages(images, duration: Self.animationDuration, for: .pulling)
        setImages(images, duration: Self.animationDuration, for: .refreshing)
    }
}
