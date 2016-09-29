//
//  UIPagingDataViewController.swift
//  Pods
//
//  Created by NGUYEN CHI CONG on 9/29/16.
//
//

import UIKit
import SiFUtilities
import PagingDataController

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
            pagingScrollView.es_startPullToRefresh()
        }
        
        
// Why could not use below method ?
//setupScrollViewForPaging(pullDownHandler: loadFirstPageWithCompletion, pullUpHandler: loadNextPageWithCompletion)
        
//        showLoading()
//        loadFirstPageWithCompletion { [weak self] in
//            self?.pagingScrollView.reloadContent()
//            self?.hideLoading()
//        }
    }
}

