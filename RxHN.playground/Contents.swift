//: Playground - noun: a place where people can play
import PlaygroundSupport
//import UIKit
import Foundation
import RxSwift
import RxCocoa


let intDriver = Observable.of(1, 2, 3, 4, 5, 6)
    .asDriver(onErrorJustReturn: 1)
    .map { $0 + 1 }
    .filter { $0 < 5 }


let intObservable = Observable.of(1, 2, 3, 4, 5, 6)
    .observeOn(MainScheduler.instance)
    .catchErrorJustReturn(1)
    .map { $0 + 1 }
    .filter { $0 < 5 }
    .shareReplay(1)

//print(intDriver)
//print(intObservable)

//Observable.of(1, 2, 3, 4, 5)
//    .scan(10, accumulator: +)
//    .subscribe { print($0) }
//    .dispose()

Observable.of(1, 2, 3, 4, 5, 6, 5, 4, 3, 2, 1)
    .takeWhile { $0 < 5 }
    .subscribe { print($0) }
    .dispose()


PlaygroundPage.current.needsIndefiniteExecution = true
