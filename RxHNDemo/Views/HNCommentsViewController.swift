//
//  HNCommentsViewController.swift
//  RxHNDemo
//
//  Created by humbertog on 2017-08-14.
//  Copyright © 2017 humbertog. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class HNCommentsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var refresh: UIActivityIndicatorView!
    
    var viewModel: HNKidViewModel!
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Comments"

        setupTableViewRx()
        setupIndicator()
        viewModel.refresh()
    }
    
    private func setupTableViewRx() {
        viewModel.elements.asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: "KidsCell", cellType: HNCommentCell.self)) { _, kid, cell in
                cell.comment.text = kid.text
                cell.author.text = kid.author
        }
        .addDisposableTo(disposeBag)
        
        tableView.rx
        .modelSelected(HNPost.self)
            .filter {
                guard let count = $0.kids?.count else { return false }
                return count > 0
            }
            .subscribe(onNext: {
                print("kids: ", $0.kids!.count)
                
                if let selectedRow = self.tableView.indexPathForSelectedRow {
                    self.tableView.deselectRow(at: selectedRow, animated: true)
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    private func setupIndicator() {
        viewModel.isLoading
            .asDriver()
            .drive(refresh.rx.isAnimating)
            .addDisposableTo(disposeBag)
    }
}
