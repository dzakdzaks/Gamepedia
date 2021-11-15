//
//  ToastViewController.swift
//  Gamepedia
//
//  Created by Dzaky on 15/11/21.
//

import UIKit

class ToastViewController: UIViewController {
    
    init(text: String) {
        super.init(nibName: nil, bundle: nil)
        
        transitioningDelegate = self
        modalPresentationStyle = .custom
        
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.numberOfLines = 0
        
        if self.traitCollection.userInterfaceStyle == .dark {
            view.backgroundColor = .white
            label.textColor = .black
        } else {
            view.backgroundColor = .black
            label.textColor = .white
        }
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ToastViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return ToastPresentationController(presentedViewController: presented, presenting: presenting)
    }
        
}
