//
//  ViewController.swift
//  Tutorials
//
//  Created by kor45cw on 10/08/2019.
//  Copyright © 2019 kor45cw. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var resultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func setInfo(by data: UserData) {
        resultLabel.text = """
                            ID: \(data.id)\n
                            Title: \(data.title)\n
                            UserId: \(data.userId)\n
                            Body: \(data.body)\n
                           """
    }
    
    private func setError() {
        resultLabel.text = """
                            ID: Error\n
                            Title: Error\n
                            UserId: Error\n
                            Body: Error\n
                           """
    }
}

extension ViewController {
    @IBAction private func created(_ sender: UIButton) {
        guard let url = URL(string: "https://github.com/kor45cw/") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction private func GET1(_ sender: UIButton) {
        API.shared.get1 { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let userDatas):
                guard let userData = userDatas.first else { return }
                self.setInfo(by: userData)
            case .failure(let error):
                print("GET1 Error", error.localizedDescription)
                self.setError()
            }
        }
    }
    
    @IBAction private func GET2(_ sender: UIButton) {
        
    }
    
    @IBAction private func POST(_ sender: UIButton) {
        
    }
    
    @IBAction private func PUT(_ sender: UIButton) {
        
    }
    
    @IBAction private func PATCH(_ sender: UIButton) {
        
    }
    
    @IBAction private func DELETE(_ sender: UIButton) {
        
    }
}
