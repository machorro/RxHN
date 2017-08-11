//
//  HNModel.swift
//  RxHNDemo
//
//  Created by humbertog on 2017-08-01.
//  Copyright © 2017 humbertog. All rights reserved.
//

import Moya
import RxSwift
import RxCocoa

protocol HNListCoordinatorViewDelegate: class {
    func openURL(_ url: URL)
    func didSelect(post: HNPost)
}

class HNListViewModel {
    typealias HNid = UInt64
    weak var coordinatorDelegate: HNListCoordinatorViewDelegate?
  
    
    let provider = RxMoyaProvider<HackerNews>()
    private let type: HackerNews
    
    var loadPageTrigger = PublishSubject<Void>()
    var loadNextPageTrigger = PublishSubject<Void>()
    let error = PublishSubject<Swift.Error>()
    var elements = Variable<[HNPost]>([])
    
    private let disposeBag = DisposeBag()
    
    var pageIndex = 0
    private let pageSize = 20
    
    
    //Driver Init
    public var moreLoading: Driver<Bool>
    public var isLoading: Driver<Bool>
    init(type: HackerNews) {
        self.type = type
        
        let Loading = ActivityIndicator()
        self.isLoading = Loading.asDriver()
        let moreLoading = ActivityIndicator()
        self.moreLoading = moreLoading.asDriver()
        
        let loadRequest = self.isLoading.asObservable()
            .sample(loadPageTrigger)
            .flatMap { isLoading -> Observable<[HNPost]> in
                if isLoading {
                    return Observable.empty()
                }
                else {
                    self.pageIndex = 0
                    self.elements.value.removeAll()
                    let (min, max) = self.pagination()
                    
                    return self.getPosts(for: self.type, min: min, max: max)
                    .trackActivity(Loading)
                }
        }
        
        let nextRequest = self.moreLoading.asObservable()
            .sample(loadNextPageTrigger)
            .flatMap { isLoading -> Observable<[HNPost]> in
                if isLoading {
                    return Observable.empty()
                }
                else {
                    self.pageIndex += 1
                    let (min, max) = self.pagination()
                    
                    return self.getPosts(for: self.type, min: min, max: max)
                    .trackActivity(moreLoading)
                }
        }
        
        let request = Observable
            .of(loadRequest, nextRequest)
            .merge()
            .shareReplay(1)
        
        let response = request.flatMap { repositories -> Observable<[HNPost]> in
            request
                .do(onError: { (error) in
                    self.error.onNext(error)
                }).catchError({ (error) -> Observable<[HNPost]> in
                    Observable.empty()
                })
            }.shareReplay(1)
        
        Observable
            .combineLatest(request, response, elements.asObservable()) { request, response, elements in
                return self.pageIndex == 0 ? response : elements + response
            }
            .sample(response)
            .debounce(0.1, scheduler: MainScheduler.instance)
            .bind(to: elements)
            .addDisposableTo(disposeBag)
    }
    
    public func refresh() {
        self.loadPageTrigger.onNext(())
    }
    
    public func didTapOpenURL(_ url: URL) {
        print("coordinate to url")
        coordinatorDelegate?.openURL(url)
    }
    
    public func didTapOnHNButton(with post: HNPost) {
        coordinatorDelegate?.didSelect(post: post)
    }
}

private extension HNListViewModel {
    private func pagination() -> (Int, Int) {
        let min = self.pageIndex * self.pageSize
        let max = ((self.pageIndex + 1) * self.pageSize) - 1
        
        return (min, max)
    }
    
    private func getPosts(for request: HackerNews, min: Int, max: Int) -> Observable<[HNPost]> {
        return getIds(for: request)
            .flatMap { (array) -> Observable<[HNPost]> in
                if max > array.count { return Observable.empty() }

                let result = array[min...max].map { id in
                    return self.getPost(with: id)
                }
                return Observable.from(result).merge().toArray()
        }
    }
    
    private func getIds(for request: HackerNews) -> Observable<[HNid]> {
        return provider
            .request(request)
            .map {
                return try! $0.mapJSON() as! [HNid]
                
            }
    }
    
    private func getPost(with id: HNid) -> Observable<HNPost> {
        return provider
            .request(.item(id: id))
            .map {
                return try! JSONDecoder().decode(HNPost.self, from: $0.data)
        }
    }
}
