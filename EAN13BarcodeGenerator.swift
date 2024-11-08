import UIKit

// Define the digit patterns for EAN-13
// Odd and even patterns for the left side and a single pattern for the right side
let leftOddPatterns = [
    "0001101", "0011001", "0010011", "0111101", "0100011", "0110001",
    "0101111", "0111011", "0110111", "0001011"
]
let leftEvenPatterns = [
    "0100111", "0110011", "0011011", "0100001", "0011101", "0111001",
    "0000101", "0010001", "0001001", "0010111"
]
let rightPatterns = [
    "1110010", "1100110", "1101100", "1000010", "1011100", "1001110",
    "1010000", "1000100", "1001000", "1110100"
]

// Function to create an EAN-13 barcode image
func drawEAN13Barcode(from code: String) -> UIImage? {
    guard code.count == 13 else { return nil }
    
    // Convert the code string to an array of Ints
    let digits = code.compactMap { Int(String($0)) }
    guard digits.count == 13 else { return nil }
    
    // Determine the left side encoding based on the first digit
    let leftEncoding = [
        ["odd", "odd", "odd", "odd", "odd", "odd"],
        ["odd", "odd", "even", "odd", "even", "even"],
        ["odd", "odd", "even", "even", "odd", "even"],
        ["odd", "odd", "even", "even", "even", "odd"],
        ["odd", "even", "odd", "odd", "even", "even"],
        ["odd", "even", "even", "odd", "odd", "even"],
        ["odd", "even", "even", "even", "odd", "odd"],
        ["odd", "even", "odd", "even", "odd", "even"],
        ["odd", "even", "odd", "even", "even", "odd"],
        ["odd", "even", "even", "odd", "even", "odd"]
    ]
    let encodingPattern = leftEncoding[digits[0]]
    
    // Start barcode string with start pattern
    var barcodePattern = "101"
    
    // Encode the left side digits
    for i in 0..<6 {
        let digit = digits[i + 1]
        let pattern = encodingPattern[i] == "odd" ? leftOddPatterns[digit] : leftEvenPatterns[digit]
        barcodePattern += pattern
    }
    
    // Middle pattern
    barcodePattern += "01010"
    
    // Encode the right side digits
    for i in 7..<13 {
        let digit = digits[i]
        barcodePattern += rightPatterns[digit]
    }
    
    // End pattern
    barcodePattern += "101"
    
    // Drawing parameters
    let width = barcodePattern.count * 4
    let height = 100
    let scaleFactor: CGFloat = 3.0
    
    // Create image context
    UIGraphicsBeginImageContext(CGSize(width: CGFloat(width) * scaleFactor, height: CGFloat(height) * scaleFactor))
    guard let context = UIGraphicsGetCurrentContext() else { return nil }
    context.scaleBy(x: scaleFactor, y: scaleFactor)
    context.setFillColor(UIColor.white.cgColor)
    context.fill(CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
    
    // Draw barcode pattern
    context.setFillColor(UIColor.black.cgColor)
    for (index, char) in barcodePattern.enumerated() {
        if char == "1" {
            context.fill(CGRect(x: CGFloat(index) * 4, y: 0, width: 3, height: CGFloat(height)))
        }
    }
    
    // Retrieve image
    let barcodeImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return barcodeImage
}
