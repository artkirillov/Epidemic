//
//  AlertViewController.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 20.07.2018.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

final class AlertViewController: UIViewController {
    
    // MARK: - Public Properties
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    var header: String?
    var message: String?
    
    // MARK: - Public Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertView.layer.cornerRadius = 10.0
        titleLabel.text = header
        descriptionLabel.text = message
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private Properties
    
    @IBOutlet private weak var alertView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
}

extension UIViewController {
    
    func showAlert(error: Error) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            if let controller = self?.storyboard?.instantiateViewController(withIdentifier: "AlertViewController") as? AlertViewController {
                controller.header = NSLocalizedString("Something has gone wrong", comment: "")
                controller.message = error.localizedDescription
                self?.present(controller, animated: true, completion: nil)
            }
        }
        
    }
    
}
