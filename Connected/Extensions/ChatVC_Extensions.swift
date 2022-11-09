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

//MARK: - ViewModel 관련
extension ChatViewController
{
    func setBindings()
    {
        print("ChatVC - setBindings()")
        
        self.userViewModel!.$userDataArray
            .debounce(for: 0.05, scheduler: RunLoop.main)
            .sink
            { (updatedArray:[Data:[AnyHashable]]) in
                print("ChatVC - datarray count: \(updatedArray.count)")
                self.userDataArray = updatedArray
                //sort dictionary by name
                self.sortedByValueDictionaryKey = self.userDataArray.sorted(by: { ($0.value[1] as! String).components(separatedBy: ".")[0] < ($1.value[1] as! String).components(separatedBy: ".")[0]}).map({$0.key})
                self.sortedByValueDictionaryValue = self.userDataArray.sorted(by: { ($0.value[1] as! String).components(separatedBy: ".")[0] < ($1.value[1] as! String).components(separatedBy: ".")[0]}).map({$0.value})
                if self.userDataArray.count > 0
                {
                    self.loadData()
                    self.tableView.scrollToBottom(isAnimated: K.didInit)
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
        snapshot.appendSections(self.sortedByValueDictionaryKey)
        snapshot.appendItems(self.sortedByValueDictionaryValue)
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

        minMaxBtn.setTitle("축소", for: .normal)
        minMaxBtn.tag = 0
        minMaxBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        minMaxBtn.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundView.addSubview(minMaxBtn)
        NSLayoutConstraint.activate([
            minMaxBtn.heightAnchor.constraint(equalToConstant: 20.0),
            minMaxBtn.leadingAnchor.constraint(equalTo: self.backgroundView.leadingAnchor, constant: 12.0),
            minMaxBtn.widthAnchor.constraint(equalToConstant: 25.0),
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

        recMinMaxBtn.setTitle("축소", for: .normal)
        recMinMaxBtn.tag = 1
        recMinMaxBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        recMinMaxBtn.translatesAutoresizingMaskIntoConstraints = false
        self.recBackgroundView.addSubview(recMinMaxBtn)
        NSLayoutConstraint.activate([
            recMinMaxBtn.heightAnchor.constraint(equalToConstant: 20.0),
            recMinMaxBtn.leadingAnchor.constraint(equalTo: self.recBackgroundView.leadingAnchor, constant: 12.0),
            recMinMaxBtn.widthAnchor.constraint(equalToConstant: 25.0),
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
            self.minMaxBtn.setTitle("확대", for: .normal)
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
                self.backgroundViewTrailingConstraint = NSLayoutConstraint(item: self.backgroundView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 88.0)
                self.backgroundViewHeightConstraint!.isActive = true
                self.backgroundViewTrailingConstraint!.isActive = true
            }
            self.minMaxBtn.removeTarget(self, action: #selector(minimizeMapView(_ :)), for: .touchUpInside)
            self.minMaxBtn.addTarget(self, action: #selector(maximizeMapView(_ :)), for: .touchUpInside)
        }
        else
        {
            self.recMinMaxBtn.setTitle("확대", for: .normal)
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
                self.recBackgroundViewTrailingConstraint = NSLayoutConstraint(item: self.recBackgroundView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 88.0)
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
            self.minMaxBtn.setTitle("축소", for: .normal)
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
            self.recMinMaxBtn.setTitle("축소", for: .normal)
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
    
}
