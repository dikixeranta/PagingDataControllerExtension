//
//  PagingInterfaceProtocol+UI.swift
//  Clip2
//
//  Created by NGUYEN CHI CONG on 8/11/16.
//  Copyright © 2016 FOLY. All rights reserved.
//

import Foundation
import SiFUtilities
import ESPullToRefresh
import PagingDataController

public typealias PullHandler = ((() -> Swift.Void)? ) -> Swift.Void

/********************************************************************************
 Copy below method to your View Controller
 ********************************************************************************
 
 override func viewDidFinishLayout() {
 super.viewDidFinishLayout()
 
 dataSource.settings = PageDataSettings(pageSize: provider.pageSize)
 dataSource.delegate = self
 
 setupScrollViewForPaging(pullDownHandler: loadFirstPageWithCompletion, pullUpHandler: loadNextPageWithCompletion)
 
 showLoading()
 loadFirstPageWithCompletion { [weak self] in
 self?.pagingScrollView.reloadContent()
 self?.hideLoading()
 }
 }
 
 *********************************************************************************/

extension UIViewController: PageDataSourceDelegate {
    
    open var instantReloadContent: Bool {
        return false
    }
    
    open var pagingScrollView: UIScrollView {
        for subview in self.view.subviews {
            if subview is UIScrollView {
                return subview as! UIScrollView
            }
        }
        fatalError("No scroll view in managed by \(self.classForCoder)")
    }
    
    // MARK: - Setup layout
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    public func setupScrollViewForPaging(pullDownHandler: @escaping PullHandler, pullUpHandler: @escaping PullHandler) {
        self.setupPullToRefreshView(pullHandler: pullDownHandler)
        self.setupInfiniteScrollingView(pullHanlder: pullUpHandler)
    }
    
    public func setupPullToRefreshView(pullHandler: @escaping PullHandler) {
        _ = pagingScrollView.es_addPullToRefresh{ [weak self] in
            pullHandler({ [weak self] in
                self?.pagingScrollView.reloadContent(instantReloadContent: (self?.instantReloadContent)!, end: {
                    [weak self] in
                    self?.pagingScrollView.es_stopPullToRefresh(completion: true)
                    })
                })
        }
    }
    
    public func setupInfiniteScrollingView(pullHanlder: @escaping PullHandler) {
        _ = pagingScrollView.es_addInfiniteScrolling { [weak self] in
            pullHanlder({ [weak self] in
                self?.pagingScrollView.reloadContent(instantReloadContent: (self?.instantReloadContent)!, end: {
                    [weak self] in
                    self?.pagingScrollView.es_stopLoadingMore()
                    })
                })
        }
    }
    
    // MARK: - Page Data Delegate
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    open func pageDataSourceDidChanged(hasMoreFlag: Bool, changed: Bool) {
        self.checkInfiniteView(hasMoreFlag)
    }
    
    // MARK: Functions
    open func checkInfiniteView(_ hasMore: Bool) {
        // call function with delay to fix mess animations
        let delayTime = DispatchTime.now() + Double(Int64(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) { [weak self] in
            
            if (hasMore == false) {
                self?.pagingScrollView.es_footer?.noMoreData = true
                self?.pagingScrollView.es_footer?.isHidden = true
            } else {
                self?.pagingScrollView.es_footer?.noMoreData = false
                self?.pagingScrollView.es_footer?.isHidden = false
            }
        }
    }
    
    open func startLoading() {
        showLoading()
    }
    
    open func stopLoading() {
        hideLoading()
    }
}

extension PagingControllerProtocol where Self: UIViewController {
    
    public func setupForPaging(loadFirstPage: Bool = true) {
        
        dataSource.settings = PageDataSettings(pageSize: provider.pageSize)
        dataSource.delegate = self
        
        _ = pagingScrollView.es_addPullToRefresh { [weak self] in
            self?.loadFirstPageWithCompletion({ [weak self] in
                self?.pagingScrollView.reloadContent(instantReloadContent: (self?.instantReloadContent)!, end: {
                    [weak self] in
                    self?.pagingScrollView.es_stopPullToRefresh(completion: true)
                    })
                })
        }
        _ = pagingScrollView.es_addInfiniteScrolling { [weak self] in
            self?.loadNextPageWithCompletion({ [weak self] in
                self?.pagingScrollView.reloadContent(instantReloadContent: (self?.instantReloadContent)!, end: {
                    [weak self] in
                    self?.pagingScrollView.es_stopLoadingMore()
                    })
                })
        }
        
        if loadFirstPage {
            startLoading()
            loadFirstPageWithCompletion({ [weak self] in
                self?.pagingScrollView.reloadContent(instantReloadContent: (self?.instantReloadContent)!, end: self?.stopLoading)
                })
        }
    }
}


