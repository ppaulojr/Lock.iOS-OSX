// LockViewController.swift
//
// Copyright (c) 2016 Auth0 (http://auth0.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import Auth0

public class LockViewController: UIViewController {

    weak var headerView: HeaderView!
    weak var scrollView: UIScrollView!
    var anchorConstraint: NSLayoutConstraint?
    var router: Router!

    public required init(lock: Lock) {
        super.init(nibName: nil, bundle: nil)
        self.router = Router(lock: lock, controller: self)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("Storyboard currently not supported")
    }

    public override func loadView() {
        let root = UIView()
        root.backgroundColor = .whiteColor()
        self.view = root

        let scrollView = UIScrollView()
        scrollView.bounces = false
        scrollView.keyboardDismissMode = .Interactive
        self.view.addSubview(scrollView)
        constraintEqual(anchor: scrollView.leftAnchor, toAnchor: self.view.leftAnchor)
        constraintEqual(anchor: scrollView.topAnchor, toAnchor: self.view.topAnchor)
        constraintEqual(anchor: scrollView.rightAnchor, toAnchor: self.view.rightAnchor)
        constraintEqual(anchor: scrollView.bottomAnchor, toAnchor: self.view.bottomAnchor)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView = scrollView

        let header = HeaderView()
        header.showClose = self.router.lock.options?.closable ?? false
        header.onClosePressed = self.router.onDismiss
        self.scrollView.addSubview(header)
        constraintEqual(anchor: header.leftAnchor, toAnchor: scrollView.leftAnchor)
        constraintEqual(anchor: header.topAnchor, toAnchor: scrollView.topAnchor)
        constraintEqual(anchor: header.rightAnchor, toAnchor: scrollView.rightAnchor)
        constraintEqual(anchor: header.widthAnchor, toAnchor: scrollView.widthAnchor)
        header.translatesAutoresizingMaskIntoConstraints = false

        self.headerView = header
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: #selector(keyboardWasShown), name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWasHidden), name: UIKeyboardWillHideNotification, object: nil)

        guard let presenter = self.router.root else { return }
        self.anchorConstraint = presenter.view.layout(inView: self.scrollView, below: self.headerView)
    }

    func keyboardWasShown(notification: NSNotification) {
        guard
            let value = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue,
            let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber,
            let curveValue = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
        else { return }
        let frame = value.CGRectValue()
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: frame.height, right: 0)

        self.scrollView.contentInset = insets
        let options = UIViewAnimationOptions(rawValue: UInt(curveValue.integerValue << 16))
        UIView.animateWithDuration(
            duration.doubleValue,
            delay: 0,
            options: options,
            animations: {
                self.anchorConstraint?.active = false
            },
            completion: nil)
    }

    func keyboardWasHidden(notification: NSNotification) {
        guard
            let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber,
            let curveValue = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            else { return }
        self.scrollView.contentInset = UIEdgeInsetsZero
        let options = UIViewAnimationOptions(rawValue: UInt(curveValue.integerValue << 16))
        UIView.animateWithDuration(
            duration.doubleValue,
            delay: 0,
            options: options,
            animations: {
                self.anchorConstraint?.active = true
            },
            completion: nil)
    }

}