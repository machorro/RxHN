//
//  HNKidViewModel.swift
//  RxHNDemo
//
//  Created by humbertog on 2017-08-14.
//  Copyright © 2017 humbertog. All rights reserved.
//

import Moya
import RxSwift
import RxCocoa

protocol HNKidListCoordinatorViewDelegate: class {
    typealias HNid = UInt64
    func didTapOn(kid: HNPost)
}

class HNKidViewModel {
    typealias HNid = UInt64
    
    weak var coordinatorDelegate: HNKidListCoordinatorViewDelegate?
    let provider = RxMoyaProvider<HackerNews>()
    
    var loadPageTrigger = PublishSubject<Void>()
    public var isLoading: Driver<Bool>
    let error = PublishSubject<Swift.Error>()
    var elements = Variable<[HNPost]>([])
    
    private let disposeBag = DisposeBag()
    
    init(kids: [HNid]) {
        let Loading = ActivityIndicator()
        self.isLoading = Loading.asDriver()
        
        self.isLoading.asObservable()
            .sample(loadPageTrigger)
            .flatMap { isLoading -> Observable<[HNPost]> in
                if isLoading {
                    return Observable.empty()
                }
                else {
                    return self.getKids(kids).trackActivity(Loading)
                }
        }
        .shareReplay(1)
        .bind(to: elements)
        .addDisposableTo(disposeBag)
    }
    
    func refresh() {
        self.loadPageTrigger.onNext(())
    }
    
    func didTapOn(comment: HNPost) {
        self.coordinatorDelegate?.didTapOn(kid: comment)
    }
    
    private func getKids(_ kids: [HNid]) -> Observable<[HNPost]> {
        let result = kids.map {
            return self.getKid(id: $0)
        }
        return Observable.from(result).merge().toArray()
    }
    
    private func getKid(id: HNid) -> Observable<HNPost> {
        return provider.request(.item(id: id))
            .map {
                return try! JSONDecoder().decode(HNPost.self, from: $0.data)
        }
    }
}
