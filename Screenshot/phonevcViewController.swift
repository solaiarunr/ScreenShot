//
//  phonevcViewController.swift
//  Screenshot
//
//  Created by HTS-PRO-2018 on 18/03/25.
//


import UIKit
import FirebaseAuth

class PhoneAuthViewController: UIViewController {

    let phoneTextField = UITextField()
    let otpTextField = UITextField()
    let sendOTPButton = UIButton()
    let verifyOTPButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        phoneTextField.placeholder = "Enter phone number"
        phoneTextField.borderStyle = .roundedRect
        phoneTextField.keyboardType = .namePhonePad
        phoneTextField.translatesAutoresizingMaskIntoConstraints = false
        
        otpTextField.placeholder = "Enter OTP"
        otpTextField.borderStyle = .roundedRect
        otpTextField.keyboardType = .numberPad
        otpTextField.translatesAutoresizingMaskIntoConstraints = false
        
        sendOTPButton.setTitle("Send OTP", for: .normal)
        sendOTPButton.backgroundColor = .systemBlue
        sendOTPButton.setTitleColor(.white, for: .normal)
        sendOTPButton.layer.cornerRadius = 5
        sendOTPButton.addTarget(self, action: #selector(sendOTP), for: .touchUpInside)
        sendOTPButton.translatesAutoresizingMaskIntoConstraints = false
        
        verifyOTPButton.setTitle("Verify OTP", for: .normal)
        verifyOTPButton.backgroundColor = .systemGreen
        verifyOTPButton.setTitleColor(.white, for: .normal)
        verifyOTPButton.layer.cornerRadius = 5
        verifyOTPButton.addTarget(self, action: #selector(verifyOTP), for: .touchUpInside)
        verifyOTPButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(phoneTextField)
        view.addSubview(sendOTPButton)
        view.addSubview(otpTextField)
        view.addSubview(verifyOTPButton)
        
        NSLayoutConstraint.activate([
            phoneTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            phoneTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            phoneTextField.widthAnchor.constraint(equalToConstant: 250),
            
            sendOTPButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sendOTPButton.topAnchor.constraint(equalTo: phoneTextField.bottomAnchor, constant: 20),
            sendOTPButton.widthAnchor.constraint(equalToConstant: 150),
            
            otpTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            otpTextField.topAnchor.constraint(equalTo: sendOTPButton.bottomAnchor, constant: 20),
            otpTextField.widthAnchor.constraint(equalToConstant: 250),
            
            verifyOTPButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            verifyOTPButton.topAnchor.constraint(equalTo: otpTextField.bottomAnchor, constant: 20),
            verifyOTPButton.widthAnchor.constraint(equalToConstant: 150)
        ])
    }
    

    @objc func sendOTP() {
        guard let phoneNumber = phoneTextField.text, !phoneNumber.isEmpty else {
            print("Enter a valid phone number")
            return
        }
        Auth.auth().settings?.isAppVerificationDisabledForTesting = true

        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
            if let error = error as NSError? {
                print("Error sending OTP: \(error.localizedDescription)")

                if let errorCode = AuthErrorCode(rawValue: error.code) {
                    switch errorCode {
                    case .quotaExceeded:
                        print("❌ Firebase OTP quota exceeded. Try again later.")
                    case .tooManyRequests:
                        print("⚠️ Too many OTP requests. Please wait before retrying.")
                    case .invalidPhoneNumber:
                        print("📵 Invalid phone number format. Ensure it includes the country code.")
                    case .networkError:
                        print("🌐 Network error. Check your internet connection.")
                    default:
                        print("🔍 Unknown error: \(error.localizedDescription)")
                    }
                }
                return
            }

            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            print("✅ OTP sent successfully!")
        }
    }

    
    // MARK: - Verify OTP
    @objc func verifyOTP() {
        guard let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") else {
            print("No verification ID found")
            return
        }
        
        guard let otpCode = otpTextField.text, !otpCode.isEmpty else {
            print("Enter the OTP code")
            return
        }
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: otpCode
        )
        
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                print("Error verifying OTP: \(error.localizedDescription)")
                return
            }
            
            print("Phone authentication successful! User ID: \(authResult?.user.uid ?? "")")
        }
    }
}

