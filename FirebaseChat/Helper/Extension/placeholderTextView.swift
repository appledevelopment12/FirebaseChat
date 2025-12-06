//
//  placeholderTextView.swift
//  FirebaseChat
//
//  Created by Rohit on 29/11/25.
//

import Foundation

import UIKit

class PlaceholderTextView: UITextView {

    // Placeholder text
    var placeholder: String = "" {
        didSet {
            placeholderLabel.text = placeholder
        }
    }

    // Placeholder text color
    var placeholderColor: UIColor = .lightGray {
        didSet {
            placeholderLabel.textColor = placeholderColor
        }
    }

    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = self.font
        label.textColor = self.placeholderColor
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override var text: String! {
        didSet {
            textDidChange()
        }
    }

    override var attributedText: NSAttributedString! {
        didSet {
            textDidChange()
        }
    }

    override var font: UIFont? {
        didSet {
            placeholderLabel.font = font
        }
    }

    override var textAlignment: NSTextAlignment {
        didSet {
            placeholderLabel.textAlignment = textAlignment
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupPlaceholderLabel()
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupPlaceholderLabel()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupPlaceholderLabel()
    }

    private func setupPlaceholderLabel() {
        addSubview(placeholderLabel)
        sendSubviewToBack(placeholderLabel)

        // Constraints for placeholderLabel
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: textContainerInset.top),
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: textContainerInset.left + textContainer.lineFragmentPadding),
            placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -(textContainerInset.right + textContainer.lineFragmentPadding)),
            placeholderLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -textContainerInset.bottom)
        ])

        textDidChange()
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextView.textDidChangeNotification, object: nil)
    }

    @objc private func textDidChange() {
        placeholderLabel.isHidden = !text.isEmpty
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidChangeNotification, object: nil)
    }
}
