//
//  DataMatrixGenerator.swift
//  SimpleQRwallet
//
//  Created by Bastiaan Quast on 11/5/24.
//

import UIKit
import CoreImage.CIFilterBuiltins

func generateDataMatrix(from dataString: String) -> UIImage? {
    // Initialize the context and Data Matrix filter
    let context = CIContext()
    guard let dataMatrixFilter = CIFilter(name: "CIDataMatrixCodeGenerator") else { return nil }
    
    // Convert the input string to data and set it as the filter's message
    let data = Data(dataString.utf8)
    dataMatrixFilter.setValue(data, forKey: "inputMessage")
    
    // Generate and return the Data Matrix code as an UIImage
    if let outputImage = dataMatrixFilter.outputImage,
       let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
        return UIImage(cgImage: cgImage)
    }
    
    return nil
}

