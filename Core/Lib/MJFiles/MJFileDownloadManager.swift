//
//  MJFileDownloadManager.swift
//
//  Created by 郭明健 on 2025/5/15.
//

import UIKit

public class MJFileDownloadManager: NSObject {
    static let shared = MJFileDownloadManager()
    
    private var downloadSuccessBlock: ((_ saveUrl: URL, _ isAlreadyExists: Bool) -> Void)?
    private var downloadFailBlock: ((_ error: Error?) -> Void)?
    private var downloadProgressBlock: ((_ progress: Float) -> Void)?
    //
    private var savedUrl: URL?
    private let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    private var currentVC: UIViewController = UIViewController()
    private var downloadSession: URLSession?
    
    // MARK: - public
    public func downloadFile(saveFileName: String,
                             fileUrl: String,
                             successBlock: ((_ saveUrl: URL, _ isAlreadyExists: Bool) -> Void)? = nil,
                             failBlock: ((_ error: Error?) -> Void)? = nil,
                             progressBlock: ((_ progress: Float) -> Void)? = nil) {
        guard let saveURL = documentPath?.appendingPathComponent(saveFileName) else {
            DispatchQueue.main.async { failBlock?(NSError(domain: "MJFileDownloadManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Documents directory unavailable"])) }
            return
        }
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: saveURL.path) {
            successBlock?(saveURL, true)
        } else {
            savedUrl = saveURL
            downloadSuccessBlock = successBlock
            downloadFailBlock = failBlock
            downloadProgressBlock = progressBlock
            beginDownload(fileUrl: fileUrl)
        }
    }
    
    public func openFile(filePath: String,
                         currentVC: UIViewController) {
        self.currentVC = currentVC
        let documentVC = UIDocumentInteractionController(url: URL(fileURLWithPath: filePath))
        documentVC.delegate = self
        documentVC.presentPreview(animated: true)
    }
    
    // MARK: - private
    private func beginDownload(fileUrl: String) {
        guard let fileURL = URL(string: fileUrl) else {
            DispatchQueue.main.async { [weak self] in
                self?.downloadFailBlock?(NSError(domain: "MJFileDownloadManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
                self?.resetBlock()
            }
            return
        }
        downloadSession?.invalidateAndCancel()
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        downloadSession = session
        session.downloadTask(with: fileURL).resume()
    }
    
    deinit {
        downloadSession?.invalidateAndCancel()
    }
    
    private func resetBlock() {
        self.downloadSuccessBlock = nil
        self.downloadProgressBlock = nil
        self.downloadFailBlock = nil
    }
}

// MARK: - URLSessionDownloadDelegate
extension MJFileDownloadManager: URLSessionDownloadDelegate {
    // 下载完成
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let dest = savedUrl else { return }
        do {
            try FileManager.default.moveItem(at: location, to: dest)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.downloadSuccessBlock?(dest, false)
                self.resetBlock()
            }
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.downloadFailBlock?(error)
                self?.resetBlock()
            }
        }
    }
    
    // 下载进度
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let progress: Float
            if totalBytesExpectedToWrite > 0 {
                progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            } else {
                progress = 0
            }
            // print("==> 文件下载进度:\(progress * 100)%")
            if let block = self.downloadProgressBlock {
                block(progress)
            }
        }
    }
    
    // 下载失败
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        session.finishTasksAndInvalidate()
        if downloadSession === session {
            downloadSession = nil
        }
        guard let error = error else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.downloadFailBlock?(error)
            self.resetBlock()
        }
    }
}

// MARK: - UIDocumentInteractionControllerDelegate
extension MJFileDownloadManager: UIDocumentInteractionControllerDelegate {
    public func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self.currentVC
    }
    
    public func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        // 关闭预览时的处理逻辑
    }
}
