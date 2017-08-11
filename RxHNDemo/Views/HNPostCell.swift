//
//  HNPostCell.swift
//  RxHNDemo
//
//  Created by humbertog on 2017-08-10.
//  Copyright © 2017 humbertog. All rights reserved.
//

import UIKit
import RxSwift

class HNPostCell: UITableViewCell {
    
    static var identifier: String = "HNPostIdentifier"
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var hostname: UILabel!
    @IBOutlet weak var points: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var comments: UILabel!
    @IBOutlet weak var button: UIButton!
    
    var post: HNPost!
    
    //Avoids calling twice the Reactive tap method
    private(set) var disposeBag = DisposeBag()
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}
