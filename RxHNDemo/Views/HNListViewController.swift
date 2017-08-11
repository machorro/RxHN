//
//  ViewController.swift
//  RxHNDemo
//
//  Created by humbertog on 2017-08-01.
//  Copyright © 2017 humbertog. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class HNListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bestButton: UIBarButtonItem!
    @IBOutlet weak var newButton: UIBarButtonItem!
    @IBOutlet weak var topButton: UIBarButtonItem!
    @IBOutlet weak var refresh: UIActivityIndicatorView!
    
    let disposeBag = DisposeBag()
    
    var viewModel: HNListViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Hacker News"
        
        setupTableViewRx()
        viewModel.refresh()
        setupScrollViewRx()
        setupButtonsRx()
        setupIndicator()
    }
    
    func setupIndicator() {
        viewModel.isLoading
            .asDriver()
            .drive(refresh.rx.isAnimating)
            .addDisposableTo(disposeBag)
        
//        viewModel.moreLoading
//            .asDriver()
//            .drive(refresh.rx.isAnimating)
//            .addDisposableTo(disposeBag)
    }
    
    func setupScrollViewRx() {
        tableView.rx.reachedBottom
            .debounce(0.3, scheduler: MainScheduler.instance)
            .map { _ in () }
            .bind(to: viewModel.loadNextPageTrigger)
            .addDisposableTo(disposeBag)
    }
    
    func setupTableViewRx() {
        tableView.dataSource = nil
        
        viewModel.elements.asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: HNPostCell.identifier, cellType: HNPostCell.self)) { _, post, cell in
                cell.post = post
                
                cell.title.text = post.title
                if var host = post.url?.host {
                    if host.contains("www."),
                        let range = host.range(of: "www.") {
                        host.removeSubrange(range)
                    }
                    cell.hostname.text = host
                }
                cell.points.text = "score: \(post.score)"
                cell.author.text = "by: \(post.author)"
                cell.comments.text = "\(post.descendants ?? 0) comments"
                
                cell.button.rx.tap
                    .subscribe { event in
                        switch event {
                        case .next:
                            print("webview with url https://news.ycombinator.com/item?id=\(cell.post.id)")
                            self.viewModel.didTapOnHNButton(with: cell.post)
                        default: break
                        }
                    }
                    .addDisposableTo(cell.disposeBag)
            }
            .addDisposableTo(disposeBag)
        
        tableView.rx
            .modelSelected(HNPost.self)
            .filter { $0.url != nil }
            .subscribe(onNext: {
                guard let url = $0.url else {
                    fatalError("This should never happen")
                }
                
                self.viewModel.didTapOpenURL(url)
                
                if let selectedRow = self.tableView.indexPathForSelectedRow {
                    self.tableView.deselectRow(at: selectedRow, animated: true)
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    func setupButtonsRx() {
        bestButton.rx.tap
            .subscribe { (event) in
                switch event {
                case .next:
                    self.loadPosts(with: .best)
                    self.viewModel.refresh()
                    self.tableView.reloadData()
                default:
                    break
                }
            }
            .addDisposableTo(disposeBag)
        
        newButton.rx.tap
            .subscribe{ (event) in
                switch event {
                case .next:
                    self.loadPosts(with: .new)
                    self.viewModel.refresh()
                    self.tableView.reloadData()
                default:
                    break
                }
            }
            .addDisposableTo(disposeBag)
        
        topButton.rx.tap
            .subscribe { (event) in
                switch event {
                case .next:
                    self.loadPosts(with: .top)
                    self.viewModel.refresh()
                    self.tableView.reloadData()
                default:
                    break
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    func loadPosts(with type: HackerNews) {
        let coordinator = viewModel.coordinatorDelegate
        viewModel = HNListViewModel(type: type)
        viewModel.coordinatorDelegate = coordinator
        setupTableViewRx()
    }
}

