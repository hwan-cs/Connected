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
        
        self.userViewModel!.$userDataArray.sink
        { (updatedArray:[Data:[Any]]) in
            print("ChatVC - datarray count: \(updatedArray.count)")
            self.userDataArray = updatedArray
            //sort dictionary by name
            self.sortedByValueDictionaryKey = self.userDataArray.sorted(by: { ($0.value[1] as! String).components(separatedBy: ".")[0] < ($1.value[1] as! String).components(separatedBy: ".")[0]}).map({$0.key})
            self.sortedByValueDictionaryValue = self.userDataArray.sorted(by: { ($0.value[1] as! String).components(separatedBy: ".")[0] < ($1.value[1] as! String).components(separatedBy: ".")[0]}).map({$0.value})
            
            DispatchQueue.main.async
            {
                self.tableView.reloadData()
            }
        }.store(in: &disposableBag)
    }
    
    func scrollToBottom()
    {
        DispatchQueue.main.async
        {
            let indexPath = IndexPath(row: (self.userViewModel?.userDataArray.count ?? 1)-1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    func initMapView()
    {
        backgroundView.backgroundColor = K.mainColor
        backgroundView.layer.cornerRadius = 20
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(backgroundView)
        self.backgroundViewHeightConstraint = NSLayoutConstraint(item: self.backgroundView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 150.0)
        self.backgroundViewHeightConstraint!.isActive = true
        self.backgroundViewTrailingConstraint = NSLayoutConstraint(item: self.backgroundView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: -8.0)
        self.backgroundViewTrailingConstraint!.isActive = true
        
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 8.0),
            backgroundView.topAnchor.constraint(equalTo: self.tableView.topAnchor, constant: 8.0),
        ])
        minMaxBtn.setTitle("축소", for: .normal)
        minMaxBtn.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundView.addSubview(minMaxBtn)
        NSLayoutConstraint.activate([
            minMaxBtn.heightAnchor.constraint(equalToConstant: 20.0),
            minMaxBtn.leadingAnchor.constraint(equalTo: self.backgroundView.leadingAnchor, constant: 8.0),
            minMaxBtn.widthAnchor.constraint(equalToConstant: 25.0),
            minMaxBtn.topAnchor.constraint(equalTo: self.backgroundView.topAnchor, constant: 10),
        ])
        minMaxBtn.addTarget(self, action: #selector(minimizeMapView), for: .touchUpInside)
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
    
    @objc func minimizeMapView()
    {
        self.minMaxBtn.setTitle("확대", for: .normal)
        self.mapView.removeFromSuperview()
        self.backgroundViewHeightConstraint!.isActive = false
        self.backgroundViewTrailingConstraint!.isActive = false
        self.backgroundView.layoutIfNeeded()
        UIView.animate(withDuration: 1.5, delay: 0.0)
        {
            var mapFrame = self.backgroundView.frame
            mapFrame.size.height = 50
            mapFrame.size.width = 80
            self.backgroundView.frame = mapFrame
            self.backgroundViewHeightConstraint = NSLayoutConstraint(item: self.backgroundView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 50)
            self.backgroundViewHeightConstraint!.isActive = true
            self.backgroundViewTrailingConstraint = NSLayoutConstraint(item: self.backgroundView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 88.0)
            self.backgroundViewTrailingConstraint!.isActive = true
        }
        self.backgroundView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handler)))
    }
    
    @objc func handler(gesture: UIPanGestureRecognizer)
    {
        let location = gesture.location(in: self.view)
        let draggedView = gesture.view
        draggedView?.center = location
        
        if gesture.state == .ended
        {
            if self.backgroundView.frame.midX >= self.view.layer.frame.width / 2
            {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations:
                {
                    self.backgroundView.center.x = self.view.layer.frame.width - 48
                }, completion: nil)
            }
            else
            {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations:
                {
                    self.backgroundView.center.x = 48
                }, completion: nil)
            }
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification)
    {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        {
            self.view.frame.origin.y -= keyboardSize.height
        }
    }

    @objc func keyboardWillHide(notification: NSNotification)
    {
        self.view.frame.origin.y = 0
    }
    
}
