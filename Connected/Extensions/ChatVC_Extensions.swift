//
//  ChatVC_Extensions.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/09/23.
//

import Foundation
import UIKit
import AVFoundation
import DSWaveformImage
import SwiftEntryKit

//MARK: - ViewModel 관련
extension ChatViewController
{
    var bottomAlertAttributes: EKAttributes
    {
        var attributes = EKAttributes.bottomFloat
        attributes.hapticFeedbackType = .success
        attributes.displayDuration = .infinity
        attributes.entryBackground = .color(color: .standardBackground)
        attributes.screenBackground = .color(color: EKColor(K.dimmedLightBackground))
        attributes.shadow = .active(
            with: .init(
                color: .black,
                opacity: 0.3,
                radius: 8
            )
        )
        attributes.screenInteraction = .dismiss
        attributes.entryInteraction = .absorbTouches
        attributes.scroll = .enabled(
            swipeable: true,
            pullbackAnimation: .jolt
        )
        attributes.roundCorners = .all(radius: 25)
        attributes.entranceAnimation = .init(
            translate: .init(
                duration: 0.7,
                spring: .init(damping: 1, initialVelocity: 0)
            ),
            scale: .init(
                from: 1.05,
                to: 1,
                duration: 0.4,
                spring: .init(damping: 1, initialVelocity: 0)
            )
        )
        attributes.exitAnimation = .init(
            translate: .init(duration: 0.2)
        )
        attributes.popBehavior = .animated(
            animation: .init(
                translate: .init(duration: 0.2)
            )
        )
        attributes.positionConstraints.verticalOffset = 10
        attributes.positionConstraints.size = .init(
            width: .offset(value: 20),
            height: .intrinsic
        )
        attributes.positionConstraints.maxSize = .init(
            width: .constant(value: UIScreen.main.bounds.minEdge),
            height: .intrinsic
        )
        attributes.statusBar = .dark
        return attributes
    }
    
    private func showPopupMessage(attributes: EKAttributes,
                                  title: String,
                                  titleColor: EKColor,
                                  description: String,
                                  descriptionColor: EKColor,
                                  buttonTitleColor: EKColor,
                                  buttonBackgroundColor: EKColor,
                                  image: UIImage? = nil) {
        
        var themeImage: EKPopUpMessage.ThemeImage?
        
        if let image = image {
            themeImage = EKPopUpMessage.ThemeImage(
                image: EKProperty.ImageContent(
                    image: image,
                    displayMode: .inferred,
                    size: CGSize(width: 60, height: 60),
                    tint: titleColor,
                    contentMode: .scaleAspectFit
                )
            )
        }
        let title = EKProperty.LabelContent(
            text: title,
            style: .init(
                font: UIFont.systemFont(ofSize: 16.0),
                color: titleColor,
                alignment: .center,
                displayMode: .inferred
            ),
            accessibilityIdentifier: "title"
        )
        let description = EKProperty.LabelContent(
            text: description,
            style: .init(
                font: UIFont.systemFont(ofSize: 16.0, weight: .medium),
                color: descriptionColor,
                alignment: .center,
                displayMode: .inferred
            ),
            accessibilityIdentifier: "description"
        )
        let button = EKProperty.ButtonContent(
            label: .init(
                text: "OK",
                style: .init(
                    font: UIFont.systemFont(ofSize: 16.0, weight: .medium),
                    color: buttonTitleColor,
                    displayMode: .inferred
                )
            ),
            backgroundColor: buttonBackgroundColor,
            highlightedBackgroundColor: buttonTitleColor.with(alpha: 0.05),
            displayMode: .inferred,
            accessibilityIdentifier: "button"
        )
        let message = EKPopUpMessage(
            themeImage: themeImage,
            title: title,
            description: description,
            button: button) {
                SwiftEntryKit.dismiss()
        }
        let contentView = EKPopUpMessageView(with: message)
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }
    
    func setBindings()
    {
        print("ChatVC - setBindings()")
        
        self.userViewModel!.$userDataArray
            .debounce(for: 0.1, scheduler: RunLoop.main)
            .sink
            { (updatedArray:[(UniqueMessage, UniqueMessageIdentifier)]) in
                print("ChatVC - datarray count: \(updatedArray.count)")
                self.userDataArray = updatedArray
                //sort dictionary by name
                self.sortedByValueDictionaryKey = self.userDataArray.sorted(by: { ($0.1.fileName).components(separatedBy: ".")[0] < ($1.1.fileName).components(separatedBy: ".")[0]}).map({$0.0})
                self.sortedByValueDictionaryValue = self.userDataArray.sorted(by: { ($0.1.fileName).components(separatedBy: ".")[0] < ($1.1.fileName).components(separatedBy: ".")[0]}).map({$0.1})
                if self.userDataArray.count > 0
                {
                    self.loadData()
                    self.tableView.scrollToBottom(isAnimated: (self.listener != nil))
                }
            }.store(in: &disposableBag)
    }
    
    func loadData()
    {
        var snapshot = self.userViewModel!.dataSource.snapshot()
        if !(self.userDataArray.count > 0)
        {
            return
        }
        snapshot.deleteAllItems()
        var keyArr = [String]()
        
        for df in zip(self.sortedByValueDictionaryKey, self.sortedByValueDictionaryValue)
        {
            if try! self.userViewModel?.cacheStorage?.existsObject(forKey: df.1.fileName) == false
            {
                self.userViewModel?.cacheStorage?.async.setObject(df.0.data!, forKey: df.1.fileName, completion: {_ in})
                print("Caching \(df.1.fileName)")
                do
                {
                    try realm.write
                    {
                        df.1.isMe ? self.userViewModel?.chat!.messages.append(df.1.fileName) : self.userViewModel?.chat!.otherMessages.append(df.1.fileName)
                    }
                }
                catch let error as NSError
                {
                    print(error.localizedDescription)
                }
            }
        }
        
        for i in self.sortedByValueDictionaryKey
        {
            keyArr.append(i.id)
        }
        snapshot.appendSections(keyArr)
        var valArr = [String]()
        for j in self.sortedByValueDictionaryValue
        {
            valArr.append(j.id)
        }
        
        do
        {
            try realm.write
            {
                self.realm.add(self.userViewModel!.chat!, update: .modified)
            }
        }
        catch let error as NSError
        {
            print(error.localizedDescription)
        }
        
        snapshot.appendItems(valArr)
        self.userViewModel!.dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func chatVCHideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(ChatViewController.chatVCDismissKeyboard))
        tap.cancelsTouchesInView = false
        self.tableView.addGestureRecognizer(tap)
    }
    
    @objc func chatVCDismissKeyboard()
    {
        view.endEditing(true)
    }
    
    func scrollToBottom()
    {
        DispatchQueue.main.async
        {
            let indexPath = IndexPath(row: (self.userViewModel?.userDataArray.count ?? 1)-1, section: 1)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    //MARK: - Initialize my map view
    func initMapView()
    {
        backgroundView.backgroundColor = K.mainColor
        backgroundView.layer.borderColor = UIColor.white.cgColor
        backgroundView.layer.borderWidth = 1.0
        backgroundView.layer.cornerRadius = 20
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(backgroundView)
        self.backgroundViewHeightConstraint?.isActive = false
        self.backgroundViewHeightConstraint = NSLayoutConstraint(item: self.backgroundView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 150.0)
        self.backgroundViewHeightConstraint!.isActive = true
        self.backgroundViewTrailingConstraint = NSLayoutConstraint(item: self.backgroundView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: -8.0)
        self.backgroundViewTrailingConstraint!.isActive = true
        self.backgroundViewLeadingConstraint = NSLayoutConstraint(item: self.backgroundView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 8.0)
        self.backgroundViewLeadingConstraint?.isActive = true
        self.backgroundViewTopAnchorConstraint = NSLayoutConstraint(item: self.backgroundView, attribute: .top, relatedBy: .equal, toItem: self.tableView, attribute: .top, multiplier: 1.0, constant: 8.0)
        self.backgroundViewTopAnchorConstraint?.isActive = true

        minMaxBtn.setTitle(K.lang == "ko" ? "축소" : "Minimize", for: .normal)
        minMaxBtn.tag = 0
        minMaxBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        minMaxBtn.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundView.addSubview(minMaxBtn)
        NSLayoutConstraint.activate([
            minMaxBtn.heightAnchor.constraint(equalToConstant: 20.0),
            minMaxBtn.leadingAnchor.constraint(equalTo: self.backgroundView.leadingAnchor, constant: 12.0),
            minMaxBtn.widthAnchor.constraint(equalToConstant: 70.0),
            minMaxBtn.topAnchor.constraint(equalTo: self.backgroundView.topAnchor, constant: 10),
        ])
        minMaxBtn.addTarget(self, action: #selector(minimizeMapView(_ :)), for: .touchUpInside)
        backgroundView.addSubview(self.mapView)
        self.mapView.layer.cornerRadius = 18
        self.mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.mapView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 32.0),
            self.mapView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 8.0),
            self.mapView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -8.0),
            self.mapView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -8.0)
        ])
    }
    
    //MARK: - Initialize recipients map view
    func initRecMapView()
    {
        recBackgroundView.backgroundColor = .lightGray
        recBackgroundView.layer.cornerRadius = 20
        recBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        recBackgroundView.layer.borderColor = UIColor.white.cgColor
        recBackgroundView.layer.borderWidth = 1.0
        self.view.addSubview(recBackgroundView)
        self.recBackgroundViewHeightConstraint = NSLayoutConstraint(item: self.recBackgroundView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 150.0)
        self.recBackgroundViewHeightConstraint!.isActive = true
        self.recBackgroundViewTrailingConstraint = NSLayoutConstraint(item: self.recBackgroundView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: -8.0)
        self.recBackgroundViewTrailingConstraint!.isActive = true
        self.recBackgroundViewLeadingConstraint = NSLayoutConstraint(item: self.recBackgroundView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 8.0)
        self.recBackgroundViewLeadingConstraint?.isActive = true
        let cons = self.backgroundView.isDescendant(of: self.view) ? 12.0+self.backgroundView.frame.height : 8.0
        self.recBackgroundViewTopAnchorConstraint = NSLayoutConstraint(item: self.recBackgroundView, attribute: .top, relatedBy: .equal, toItem: self.tableView, attribute: .top, multiplier: 1.0, constant: cons)
        self.recBackgroundViewTopAnchorConstraint?.isActive = true

        recMinMaxBtn.setTitle(K.lang == "ko" ? "축소" : "Minimize", for: .normal)
        recMinMaxBtn.tag = 1
        recMinMaxBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        recMinMaxBtn.translatesAutoresizingMaskIntoConstraints = false
        self.recBackgroundView.addSubview(recMinMaxBtn)
        NSLayoutConstraint.activate([
            recMinMaxBtn.heightAnchor.constraint(equalToConstant: 20.0),
            recMinMaxBtn.leadingAnchor.constraint(equalTo: self.recBackgroundView.leadingAnchor, constant: 12.0),
            recMinMaxBtn.widthAnchor.constraint(equalToConstant: 70.0),
            recMinMaxBtn.topAnchor.constraint(equalTo: self.recBackgroundView.topAnchor, constant: 10),
        ])
        recMinMaxBtn.addTarget(self, action: #selector(minimizeMapView(_ :)), for: .touchUpInside)
        recBackgroundView.addSubview(self.recMapView)
        self.recMapView.layer.cornerRadius = 18
        self.recMapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.recMapView.topAnchor.constraint(equalTo: recBackgroundView.topAnchor, constant: 32.0),
            self.recMapView.leadingAnchor.constraint(equalTo: recBackgroundView.leadingAnchor, constant: 8.0),
            self.recMapView.trailingAnchor.constraint(equalTo: recBackgroundView.trailingAnchor, constant: -8.0),
            self.recMapView.bottomAnchor.constraint(equalTo: recBackgroundView.bottomAnchor, constant: -8.0)
        ])
    }
    
    @objc func minimizeMapView(_ sender: UIButton)
    {
        if sender.tag == 0
        {
            self.minMaxBtn.setTitle(K.lang == "ko" ? "확대" : "Maximize", for: .normal)
            self.mapView.removeFromSuperview()
            self.backgroundViewHeightConstraint!.isActive = false
            self.backgroundViewTrailingConstraint!.isActive = false
            self.backgroundView.layoutIfNeeded()
            UIView.animate(withDuration: 1.0, delay: 0.0)
            {
                var mapFrame = self.backgroundView.frame
                mapFrame.size.height = 50
                mapFrame.size.width = 80
                self.backgroundView.frame = mapFrame
                var mapViewFrame = self.mapView.frame
                mapViewFrame.size.height = 0
                mapViewFrame.size.width = 0
                self.mapView.frame = mapViewFrame
                self.backgroundViewHeightConstraint = NSLayoutConstraint(item: self.backgroundView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 50.0)
                self.backgroundViewTrailingConstraint = NSLayoutConstraint(item: self.backgroundView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 100.0)
                self.backgroundViewHeightConstraint!.isActive = true
                self.backgroundViewTrailingConstraint!.isActive = true
            }
            self.minMaxBtn.removeTarget(self, action: #selector(minimizeMapView(_ :)), for: .touchUpInside)
            self.minMaxBtn.addTarget(self, action: #selector(maximizeMapView(_ :)), for: .touchUpInside)
        }
        else
        {
            self.recMinMaxBtn.setTitle(K.lang == "ko" ? "확대" : "Maximize", for: .normal)
            self.recMapView.removeFromSuperview()
            self.recBackgroundViewHeightConstraint!.isActive = false
            self.recBackgroundViewTrailingConstraint!.isActive = false
            self.recBackgroundView.layoutIfNeeded()
            UIView.animate(withDuration: 1.0, delay: 0.0)
            {
                var mapFrame = self.recBackgroundView.frame
                mapFrame.size.height = 50
                mapFrame.size.width = 80
                self.recBackgroundView.frame = mapFrame
                var mapViewFrame = self.recMapView.frame
                mapViewFrame.size.height = 0
                mapViewFrame.size.width = 0
                self.recMapView.frame = mapViewFrame
                self.recBackgroundViewHeightConstraint = NSLayoutConstraint(item: self.recBackgroundView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 50.0)
                self.recBackgroundViewTrailingConstraint = NSLayoutConstraint(item: self.recBackgroundView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 100.0)
                self.recBackgroundViewHeightConstraint!.isActive = true
                self.recBackgroundViewTrailingConstraint!.isActive = true
            }
            self.recMinMaxBtn.removeTarget(self, action: #selector(minimizeMapView(_ :)), for: .touchUpInside)
            self.recMinMaxBtn.addTarget(self, action: #selector(maximizeMapView(_ :)), for: .touchUpInside)
        }
    }
    
    @objc func maximizeMapView(_ sender: UIButton)
    {
        if sender.tag == 0
        {
            self.minMaxBtn.setTitle(K.lang == "ko" ? "축소" : "Minimize", for: .normal)
            self.backgroundView.addSubview(self.mapView)
            self.backgroundViewHeightConstraint!.isActive = false
            self.backgroundViewTrailingConstraint!.isActive = false
            UIView.animate(withDuration: 1.0, delay: 0.0)
            {
                var mapFrame = self.backgroundView.frame
                mapFrame.size.height = 150
                mapFrame.size.width = self.view.frame.size.width
                self.backgroundView.frame = mapFrame
                var mapViewFrame = self.mapView.frame
                mapViewFrame.size.height = 150
                mapViewFrame.size.width = self.view.frame.size.width
                self.mapView.frame = mapViewFrame
                self.backgroundViewLeadingConstraint?.isActive = false
                self.backgroundViewLeadingConstraint = NSLayoutConstraint(item: self.backgroundView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 8.0)
                self.backgroundViewLeadingConstraint?.isActive = true
                self.backgroundViewHeightConstraint = NSLayoutConstraint(item: self.backgroundView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 150)
                self.backgroundViewHeightConstraint!.isActive = true
                self.backgroundViewTrailingConstraint = NSLayoutConstraint(item: self.backgroundView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: -8.0)
                self.backgroundViewTrailingConstraint!.isActive = true
            }
            NSLayoutConstraint.activate([
                self.mapView.topAnchor.constraint(equalTo: self.backgroundView.topAnchor, constant: 32.0),
                self.mapView.leadingAnchor.constraint(equalTo: self.backgroundView.leadingAnchor, constant: 8.0),
                self.mapView.trailingAnchor.constraint(equalTo: self.backgroundView.trailingAnchor, constant: -8.0),
                self.mapView.bottomAnchor.constraint(equalTo: self.backgroundView.bottomAnchor, constant: -8.0)
            ])
            self.minMaxBtn.removeTarget(self, action: #selector(maximizeMapView(_ :)), for: .touchUpInside)
            self.minMaxBtn.addTarget(self, action: #selector(minimizeMapView(_ :)), for: .touchUpInside)
        }
        else
        {
            self.recMinMaxBtn.setTitle(K.lang == "ko" ? "축소" : "Minimize", for: .normal)
            self.recBackgroundView.addSubview(self.recMapView)
            self.recBackgroundViewHeightConstraint!.isActive = false
            self.recBackgroundViewTrailingConstraint!.isActive = false
            UIView.animate(withDuration: 1.0, delay: 0.0)
            {
                var mapFrame = self.recBackgroundView.frame
                mapFrame.size.height = 150
                mapFrame.size.width = self.view.frame.size.width
                self.recBackgroundView.frame = mapFrame
                var mapViewFrame = self.recMapView.frame
                mapViewFrame.size.height = 150
                mapViewFrame.size.width = self.view.frame.size.width
                self.recMapView.frame = mapViewFrame
                self.recBackgroundViewLeadingConstraint?.isActive = false
                self.recBackgroundViewLeadingConstraint = NSLayoutConstraint(item: self.recBackgroundView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 8.0)
                self.recBackgroundViewLeadingConstraint?.isActive = true
                self.recBackgroundViewHeightConstraint = NSLayoutConstraint(item: self.recBackgroundView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 150)
                self.recBackgroundViewHeightConstraint!.isActive = true
                self.recBackgroundViewTrailingConstraint = NSLayoutConstraint(item: self.recBackgroundView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: -8.0)
                self.recBackgroundViewTrailingConstraint!.isActive = true
            }
            NSLayoutConstraint.activate([
                self.recMapView.topAnchor.constraint(equalTo: self.recBackgroundView.topAnchor, constant: 32.0),
                self.recMapView.leadingAnchor.constraint(equalTo: self.recBackgroundView.leadingAnchor, constant: 8.0),
                self.recMapView.trailingAnchor.constraint(equalTo: self.recBackgroundView.trailingAnchor, constant: -8.0),
                self.recMapView.bottomAnchor.constraint(equalTo: self.recBackgroundView.bottomAnchor, constant: -8.0)
            ])
            self.recMinMaxBtn.removeTarget(self, action: #selector(maximizeMapView(_ :)), for: .touchUpInside)
            self.recMinMaxBtn.addTarget(self, action: #selector(minimizeMapView(_ :)), for: .touchUpInside)
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification)
    {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        {
            if K.frameHeight == self.view.frame.origin.y
            {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification)
    {
        self.view.frame.origin.y = 0
    }
    
    func setupPopupPresets(completionHandler: @escaping (Bool) -> Void)
    {
        var presets: [PresetDescription] = []
        var attributes: EKAttributes
        var description: PresetDescription
        var descriptionString: String
        var descriptionThumb: String

        // Preset V
        attributes = .centerFloat
        attributes.displayMode = .inferred
        attributes.windowLevel = .alerts
        attributes.displayDuration = .infinity
        attributes.hapticFeedbackType = .success
        attributes.screenInteraction = .absorbTouches
        attributes.entryInteraction = .absorbTouches
        attributes.scroll = .disabled
        attributes.screenBackground = .color(color: EKColor(light: K.dimmedLightBackground, dark: K.dimmedDarkBackground))
        attributes.entryBackground = .color(color: .white)
        attributes.roundCorners = .all(radius: 16.0)
        attributes.entranceAnimation = .init(
            scale: .init(
                from: 0.9,
                to: 1,
                duration: 0.4,
                spring: .init(damping: 1, initialVelocity: 0)
            ),
            fade: .init(
                from: 0,
                to: 1,
                duration: 0.3
            )
        )
        attributes.exitAnimation = .init(
            fade: .init(
                from: 1,
                to: 0,
                duration: 0.2
            )
        )
        attributes.shadow = .active(
            with: .init(
                color: .black,
                opacity: 0.3,
                radius: 5
            )
        )
        attributes.positionConstraints.maxSize = .init(
            width: .constant(value: UIScreen.main.bounds.minEdge),
            height: .intrinsic
        )
        descriptionString = K.lang == "ko" ? "실시간 위치 공유" : "Live location sharing"
        descriptionThumb = "loc.circle"
        description = .init(
            with: attributes, title: "Center Alert View",
            description: descriptionString,
            thumb: descriptionThumb
        )
        presets.append(description)
        self.showAlertView(attributes: attributes)
        { success in
            if success
            {
                completionHandler(true)
            }
            completionHandler(false)
        }
    }
    
    func showAlertView(attributes: EKAttributes, completionHandler: @escaping (Bool) -> Void)
    {
        let title = EKProperty.LabelContent(
            text: K.lang == "ko" ? "실시간 위치 공유" : "Live location sharing",
            style: .init(
                font: UIFont.systemFont(ofSize: 15.0, weight: .medium),
                color: .black,
                alignment: .center,
                displayMode: .inferred
            )
        )
        let text = K.lang == "ko" ?
        """
        실시간 위치 공유를 허용 하시겠습니다? \n
        설정에서 "위치 허용"을 안하셨다면 해주세요! \n
        설정 -> 커넥티드 -> 위치 -> 앱을 사용하는 동안 ✅\n
        """
        :
        """
        Allow live location sharing? \n
        If you haven't allowed location in Settings, please do so! \n
        Settings -> Connected -> Location -> When in use ✅\n
        """
        let description = EKProperty.LabelContent(
            text: text,
            style: .init(
                font: UIFont.systemFont(ofSize: 13.0),
                color: .black,
                alignment: .center,
                displayMode: .inferred
            )
        )
        let image = EKProperty.ImageContent(
            imageName: "loc.circle",
            displayMode: .inferred,
            size: CGSize(width: 25, height: 25),
            contentMode: .scaleAspectFit,
            tint: EKColor(K.mainColor)
        )
        let simpleMessage = EKSimpleMessage(
            image: image,
            title: title,
            description: description
        )
        let buttonFont = UIFont.systemFont(ofSize: 16.0)
        let closeButtonLabelStyle = EKProperty.LabelStyle(
            font: buttonFont,
            color: EKColor(.systemGray4),
            displayMode: .inferred
        )
        let closeButtonLabel = EKProperty.LabelContent(
            text: K.lang == "ko" ? "나중에" : "Maybe later",
            style: closeButtonLabelStyle
        )
        let closeButton = EKProperty.ButtonContent(
            label: closeButtonLabel,
            backgroundColor: .clear,
            highlightedBackgroundColor: EKColor(.systemGray4).with(alpha: 0.05),
            displayMode: .inferred)
            {
                SwiftEntryKit.dismiss()
                completionHandler(false)
            }
        let okButtonLabelStyle = EKProperty.LabelStyle(
            font: buttonFont,
            color: EKColor(.systemTeal),
            displayMode: .inferred
        )
        let okButtonLabel = EKProperty.LabelContent(
            text: K.lang == "ko" ? "공유하기" : "Share",
            style: okButtonLabelStyle
        )
        let okButton = EKProperty.ButtonContent(
            label: okButtonLabel,
            backgroundColor: .clear,
            highlightedBackgroundColor: EKColor(.systemTeal).with(alpha: 0.05),
            displayMode: .inferred,
            accessibilityIdentifier: "ok-button"){ [unowned self] in
            var attributes = self.bottomAlertAttributes
            attributes.entryBackground = .color(color: EKColor(.systemTeal))
            attributes.entranceAnimation = .init(translate: .init(duration: 0.65, spring: .init(damping: 0.8, initialVelocity: 0)))
                let image = UIImage(systemName: "checkmark.circle.fill")
                let title = ""
                let description = K.lang == "ko" ? "실시간 위치를 공유 중입니다." : "Sharing live location"
                self.showPopupMessage(
                    attributes: attributes,
                    title: title,
                    titleColor: .white,
                    description: description,
                    descriptionColor: .white,
                    buttonTitleColor: .init(.gray),
                    buttonBackgroundColor: .white,
                    image: image
                )
                completionHandler(true)
            }
        // Generate the content
        let buttonsBarContent = EKProperty.ButtonBarContent(
            with: okButton, closeButton,
            separatorColor: EKColor(.lightGray),
            displayMode: .inferred,
            expandAnimatedly: true
        )
        let alertMessage = EKAlertMessage(
            simpleMessage: simpleMessage,
            buttonBarContent: buttonsBarContent
        )
        let contentView = EKAlertMessageView(with: alertMessage)
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }
}
