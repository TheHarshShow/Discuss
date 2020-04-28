//
//  PhotoSelectorController.swift
//  Discuss
//
//  Created by Harsh Motwani on 12/04/20.
//  Copyright © 2020 Harsh Motwani. All rights reserved.
//

import UIKit
import Firebase

class PostViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var fontPickerView = UIPickerView()

    var colorPickerView = UIPickerView()
    
    var imagePicked: UIImage? {
        
        didSet {
            
            self.stampImageView.image = imagePicked
            
        }
        
    }
    
    let infoLabel: UILabel = {
       
        let label = UILabel()
        label.text = "Click the stamp to change background image*"
        label.textColor = .systemRed
        label.adjustsFontSizeToFitWidth = true
        
        return label
        
    }()
    
    let stampImageView: UIImageView = {
        
        let iv = UIImageView()
        
        iv.backgroundColor = .systemTeal
        iv.layer.cornerRadius = 5
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true

        return iv
        
    }()
    
    let choosePhotoButton: UIButton = {
        
        let button = UIButton();
        button.setTitle("", for: .normal)
        
        return button
        
        
    }()
    
    let postTextField: UITextField = {
        
        let tf = UITextField()
        
        tf.backgroundColor = .systemGray3
        tf.font = UIFont.boldSystemFont(ofSize: 20)
        tf.placeholder = "Post Title"
        tf.layer.cornerRadius = 3
        tf.textAlignment = .center
        
        return tf
        
    }()
    
    var fonts = [String]()
    
    var colors = [String]()
    
    var colorPicked: String?
    
    let countLabel: UILabel = {
        
        let label = UILabel()
        
        label.text = "21"
        label.font = UIFont.boldSystemFont(ofSize: 23)
        label.textColor = .green
        
        return label
        
    }()
    
    let titleLabel: UITextView = {
        
        let label = UITextView()
        
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textAlignment = .center
        label.backgroundColor = .none
        label.layer.cornerRadius = 5
        label.clipsToBounds = true
        label.isEditable = false
        label.isScrollEnabled = false
        
        return label
        
    }()
    let colorTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Choose Color"
        tf.textAlignment = .center
        tf.font = UIFont.boldSystemFont(ofSize: 15)
        tf.borderStyle = .roundedRect
        return tf
    }()
    
    let fontTextField: UITextField = {
        
        let tf = UITextField()
        tf.placeholder = "Choose Font"
        tf.textAlignment = .center
        tf.font = UIFont.boldSystemFont(ofSize: 15)
        tf.borderStyle = .roundedRect
        return tf
        
    }()
    
    let db = Firestore.firestore()
    
    var temporaryConstraint: NSLayoutConstraint?
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == fontPickerView { return fonts[row] }
        else if pickerView == colorPickerView { return colors[row] }
        else { return "PickerViewItemTitle" }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == fontPickerView {
            fontTextField.text = fonts[row]
            postTextField.font = UIFont(name: fonts[row], size: 14)
            fontTextField.font = UIFont(name: fonts[row], size: 14)
            titleLabel.font = UIFont(name: fonts[row], size: 14)
            colorTextField.font = UIFont(name: fonts[row], size: 14)
        } else if pickerView == colorPickerView {
            fontTextField.textColor = colorDict[colors[row]]
            postTextField.textColor = colorDict[colors[row]]
            titleLabel.textColor = colorDict[colors[row]]
            colorTextField.textColor = colorDict[colors[row]]
            colorTextField.text = colors[row]
            colorPicked = colors[row]
        }
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == fontPickerView {
            return fonts.count
        } else if pickerView == colorPickerView{
            return colors.count
        } else {
            return 0
        }
    }

    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField ==  postTextField{
                        
            let currentText = postTextField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else {
                return false
            }
            let updateText = currentText.replacingCharacters(in: stringRange, with: string)
            if updateText.count > 21 { return false }
            
            countLabel.text = "\(21-(postTextField.text?.count ?? 0))"
            countLabel.text = "\(21-updateText.count)"
            titleLabel.text = updateText
            
            switch updateText.count {
            case let x where x <= 10:
                countLabel.textColor = .green
            case let x where x <= 15:
                countLabel.textColor = .systemYellow
            default:
                countLabel.textColor = .red
            }
            
            return updateText.count <= 21
            
        } else if textField == fontTextField || textField == colorTextField {
            
            return false
            
        }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFontNames()
        
        fontPickerView.delegate = self
        fontPickerView.dataSource = self
        fontPickerView.reloadAllComponents()
        
        colors = Array(colorDict.keys)
        colorPickerView.delegate = self
        colorPickerView.dataSource = self
        colorPickerView.reloadAllComponents()
        
        fontTextField.inputView = fontPickerView
        colorTextField.inputView = colorPickerView
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        view.backgroundColor = .tertiarySystemBackground
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        choosePhotoButton.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
        
        setupNavigationButtons()
        
        setupUIElements()
    }
    
    fileprivate func setupFontNames(){
        
        for fam in UIFont.familyNames {
            
            let newfonts = UIFont.fontNames(forFamilyName: fam)
            fonts += newfonts
            
        }
        
    }
    
    fileprivate func setupUIElements(){
        
        self.view.addSubview(postTextField)
        self.view.addSubview(countLabel)
        self.view.addSubview(fontTextField)
        self.view.addSubview(stampImageView)
        self.view.addSubview(titleLabel)
        self.view.addSubview(choosePhotoButton)
        self.view.addSubview(colorTextField)
        self.view.addSubview(infoLabel)

        
        postTextField.delegate = self
        fontTextField.delegate = self
        colorTextField.delegate = self
        
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        colorTextField.translatesAutoresizingMaskIntoConstraints = false
        choosePhotoButton.translatesAutoresizingMaskIntoConstraints = false
        fontTextField.translatesAutoresizingMaskIntoConstraints = false
//        fontLabel.translatesAutoresizingMaskIntoConstraints = false
        postTextField.translatesAutoresizingMaskIntoConstraints = false
//        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        stampImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
        
            choosePhotoButton.leftAnchor.constraint(equalTo: self.stampImageView.leftAnchor),
            choosePhotoButton.topAnchor.constraint(equalTo: self.stampImageView.topAnchor),
            choosePhotoButton.rightAnchor.constraint(equalTo: self.stampImageView.rightAnchor),
            choosePhotoButton.bottomAnchor.constraint(equalTo: self.stampImageView.bottomAnchor),

            stampImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            stampImageView.heightAnchor.constraint(equalToConstant: 100),
            stampImageView.widthAnchor.constraint(equalToConstant: 100),
            stampImageView.bottomAnchor.constraint(equalTo: fontTextField.topAnchor, constant: -30),
            
            postTextField.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -10),
            postTextField.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10),
            postTextField.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            postTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: 30),
            
            infoLabel.bottomAnchor.constraint(equalTo: stampImageView.topAnchor, constant: -10),
            infoLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -10),
            infoLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10),
            infoLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
            
            countLabel.leftAnchor.constraint(equalTo: postTextField.leftAnchor),
            countLabel.bottomAnchor.constraint(equalTo: postTextField.topAnchor, constant: -10),
            countLabel.widthAnchor.constraint(equalToConstant: 50),
            countLabel.heightAnchor.constraint(equalToConstant: 25),
            
            fontTextField.topAnchor.constraint(equalTo: countLabel.topAnchor),
            fontTextField.leftAnchor.constraint(equalTo: countLabel.rightAnchor, constant: 10),
            fontTextField.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -10),
            fontTextField.bottomAnchor.constraint(equalTo: countLabel.bottomAnchor),
            
            titleLabel.leftAnchor.constraint(equalTo: stampImageView.leftAnchor),
            titleLabel.rightAnchor.constraint(equalTo: stampImageView.rightAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: stampImageView.centerYAnchor),
            titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),

            colorTextField.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -10),
            colorTextField.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10),
            colorTextField.topAnchor.constraint(equalTo: self.postTextField.bottomAnchor, constant: 10),
            colorTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: 30),
            
        ])
        
    }
    
    @objc func keyboardWillShow(notification: Notification) {

       if let userInfo = notification.userInfo {
            
        guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            temporaryConstraint?.constant = -keyboardFrame.height + view.safeAreaInsets.bottom - 10
            
        }

        
    }

    @objc func keyboardWillHide(notification: Notification) {
        
        temporaryConstraint?.constant = -20
        

    }
    
    fileprivate func setupNavigationButtons(){
        
        navigationController?.navigationBar.tintColor = .label
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNext))
        
    }
    
    @objc fileprivate func handleNext(){
        
        if postTextField.text?.count ?? 0 == 0 {
            
            let alert = UIAlertController(title: "No Title Provided", message: "Please Fill in the Title field", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        }
        
        let postfinalPage = PostFinalPage()
        postfinalPage.postImage = imagePicked
        postfinalPage.postTitle = postTextField.text
        postfinalPage.color = colorPicked
        if fontTextField.text?.count ?? 0 > 0 {
            postfinalPage.font = fontTextField.text
        }
        
        navigationController?.pushViewController(postfinalPage, animated: true)
        
        
    }
    
    @objc fileprivate func handleCancel(){
        
        self.dismiss(animated: true, completion: nil)
        
    }
    

    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    @objc func handleSelectPhoto(){
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        self.present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            imagePicked = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerOriginalImage")] as? UIImage {
            imagePicked = originalImage
        }
        
        dismiss(animated: true, completion: nil)

    }
    
}
