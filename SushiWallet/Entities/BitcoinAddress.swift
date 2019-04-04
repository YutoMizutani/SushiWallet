//
//  BitcoinAddress.swift
//  SushiWallet
//
//  Created by ym on 2019/04/05.
//  Copyright © 2019 Yuto Mizutani. All rights reserved.
//

import UIKit

struct BitcoinAddress {
    private var address: String
    var value: String {
        return address
    }

    init(_ address: String) {
        self.address = address
    }
}

extension BitcoinAddress {
    func generateQRCode() -> UIImage? {
        let parameters: [String : Any] = [
            "inputMessage": address.data(using: .utf8)!,
            "inputCorrectionLevel": "L"
        ]
        let filter = CIFilter(name: "CIQRCodeGenerator", parameters: parameters)

        guard let outputImage = filter?.outputImage else {
            return nil
        }

        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: 6, y: 6))
        guard let cgImage = CIContext().createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}
