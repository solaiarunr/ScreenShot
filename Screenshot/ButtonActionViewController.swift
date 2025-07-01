//
//  ButtonActionViewController.swift
//  Screenshot
//
//  Created by HTS-PRO-2018 on 08/05/25.
//

import UIKit

class ButtonActionViewController: UIViewController {
    var isCashSelected = false
    var isWalletSelected = false
    var isStripeSelected = false
    var isRazorpaySelected = false
    @IBOutlet weak var cashButton: UIButton!
    @IBOutlet weak var walletButton: UIButton!
    @IBOutlet weak var stripeButton: UIButton!
    @IBOutlet weak var razorpayButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func cashButtonTapped(_ sender: UIButton) {
        print("qwerty1")
        isCashSelected.toggle()
        
        if isCashSelected {
            isWalletSelected = false
            isStripeSelected = false
            isRazorpaySelected = false
        }

        updateButtonStates()
    }

    @IBAction func walletButtonTapped(_ sender: UIButton) {
        print("qwerty2")
        isWalletSelected.toggle()

        if isWalletSelected {
            isCashSelected = false
        } else {
            isStripeSelected = false
            isRazorpaySelected = false
        }

        updateButtonStates()
    }

    @IBAction func stripeButtonTapped(_ sender: UIButton) {
        print("qwerty3")
        isStripeSelected.toggle()

        if isStripeSelected {
            isCashSelected = false
            isRazorpaySelected = false
        }

        updateButtonStates()
    }

    @IBAction func razorpayButtonTapped(_ sender: UIButton) {
        print("qwerty4")
        isRazorpaySelected.toggle()

        if isRazorpaySelected {
            isCashSelected = false
            isStripeSelected = false
        }

        updateButtonStates()
    }

    func updateButtonStates() {
        // Update UI (e.g., background color or checkmark)
        cashButton.isSelected = isCashSelected
        walletButton.isSelected = isWalletSelected
        stripeButton.isSelected = isStripeSelected
        razorpayButton.isSelected = isRazorpaySelected

        // Optional: disable buttons based on logic
        stripeButton.isEnabled = isWalletSelected || !isWalletSelected
        razorpayButton.isEnabled = isWalletSelected || !isWalletSelected
    }



}



