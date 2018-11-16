//
//  PickerViewController.swift
//  Coins
//
//  Created by Artem Kirillov on 12/11/2018.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

final class PickerViewController: UIViewController {
    
    // MARK: - Public Nested
    
    enum Element {
        case date
        case time
        case exchange
        case traidingPair
    }
    
    // MARK: - Public Properties
    
    static let identifier = String(describing: PickerViewController.self)
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Constructors
    
    init(element: Element) {
        
        self.element = element
        
        switch element {
        case .date:         picker = UIPickerView()
        case .time:         picker = UIPickerView()
        case .exchange:     picker = UIPickerView()
        case .traidingPair: picker = UIPickerView()
        }
        
        super.init(nibName: nil, bundle: nil)
        
        picker.dataSource = self
        picker.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        
        containerView.alpha = 0.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        containerView.transform = CGAffineTransform(translationX: 0.0, y: containerView.bounds.height)
        containerView.alpha = 1.0
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0.0,
            options: .curveEaseOut,
            animations: { self.containerView.transform = CGAffineTransform.identity },
            completion: nil)
    }
    
    
    // MARK: - Private Properties
    
    private let element: Element
    private let picker: UIPickerView
    private let effectView = UIVisualEffectView()
    private let containerView = UIView()
    private let doneButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    
}

// MARK: - UIPickerViewDataSource

extension PickerViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 20
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(component) - \(row)"
    }
    
}

// MARK: - UIPickerViewDelegate

extension PickerViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("--- select \(component) - \(row)")
    }
}

private extension PickerViewController {
    
    // MARK: - Private Methods
    
    func setupViews() {
        
        view.backgroundColor = .clear
        
        view.addSubview(containerView)
        
        containerView.addSubview(effectView)
        effectView.effect = UIBlurEffect(style: .dark)
        
        containerView.addSubview(cancelButton)
        containerView.addSubview(doneButton)
        containerView.addSubview(picker)
        
        picker.tintColor = Colors.majorTextColor
        picker.backgroundColor = Colors.pickerBackgroundColor
        
        cancelButton.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        cancelButton.setTitleColor(Colors.majorTextColor, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        doneButton.setTitle(NSLocalizedString("Done", comment: ""), for: .normal)
        doneButton.setTitleColor(Colors.majorTextColor, for: .normal)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
    }
    
    func setupConstraints() {
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        effectView.translatesAutoresizingMaskIntoConstraints = false
        effectView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        effectView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        effectView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        effectView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        cancelButton.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        cancelButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        doneButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        doneButton.bottomAnchor.constraint(equalTo: picker.topAnchor).isActive = true
        doneButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        doneButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        picker.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        picker.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        containerView.transform = CGAffineTransform(translationX: 0.0, y: containerView.bounds.height)
    }
    
    @objc func cancelButtonTapped() {
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0.0,
            options: .curveEaseOut,
            animations: { self.containerView.transform = CGAffineTransform(translationX: 0.0, y: self.containerView.bounds.height) },
            completion: { _ in self.dismiss(animated: false, completion: nil) })
    }
    
    @objc func doneButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
}
