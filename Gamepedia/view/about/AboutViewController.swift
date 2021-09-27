//
//  AboutViewController.swift
//  Gamepedia
//
//  Created by Dzaky on 24/09/21.
//

import UIKit

class AboutViewController: UIViewController {
    
    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet var imageProfle: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    private func setup() {
        title = "About"
        navigationItem.title = "My Profile"
        
        labelName.text = ProfileModel.name
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "pencil"), style: .plain, target: self, action: #selector(editProfile(sender:)))
    }
    
    @objc private func editProfile(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Edit Profile", message: "", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = ProfileModel.name
        }
        
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            guard let textField =  alert.textFields?.first else {
                return
            }
            
            ProfileModel.name = textField.text ?? "Muhammad Dzaky Rahmanto"
            ProfileModel.synchronize()
            self.labelName.text = ProfileModel.name
        })
        
        alert.addAction(UIAlertAction(title: "Discard", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }}
