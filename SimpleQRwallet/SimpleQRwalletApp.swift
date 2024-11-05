import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \QRCard.label, ascending: true)],
        animation: .default)
    private var qrCards: FetchedResults<QRCard>

    @State private var showAddCardView = false
    @State private var selectedCard: QRCard? = nil // State variable for selected card

    var body: some View {
        NavigationView {
            List {
                ForEach(qrCards) { card in
                    Button(action: {
                        selectedCard = card // Set the selected card when tapped
                    }) {
                        Text(card.label ?? "Unknown Label")
                    }
                }
                .onDelete(perform: deleteCards)
            }
            .navigationBarTitle("QR Wallet")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddCardView = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(item: $selectedCard) { card in
                QRCardDetailView(card: card) // Show details in a pop-up sheet
            }
            .sheet(isPresented: $showAddCardView) {
                AddCardView()
            }
        }
    }

    private func deleteCards(offsets: IndexSet) {
        withAnimation {
            offsets.map { qrCards[$0] }.forEach(viewContext.delete)
            try? viewContext.save()
        }
    }
}

// Detail View for Displaying Selected Card Data
import CoreImage.CIFilterBuiltins

struct QRCardDetailView: View {
    let card: QRCard
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Text(card.label ?? "No Label")
                .font(.largeTitle)
                .padding()

            // Generate and display the barcode or QR code image
            if let codeImage = generateCodeImage(for: card) {
                Image(uiImage: codeImage)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 100)
                    .padding()
            } else {
                Text("Invalid data or type")
                    .foregroundColor(.red)
            }

            Button("Done") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
        }
    }

    // Generate code image based on card type
    private func generateCodeImage(for card: QRCard) -> UIImage? {
        switch card.type {
        case "QRCode":
            return generateQRCode(from: card.data ?? "")
        case "EAN13":
            return drawEAN13Barcode(from: card.data ?? "") // Uses function from EAN13BarcodeGenerator.swift
        default:
            return nil
        }
    }

    // Function to generate a QR code using Core Image
    private func generateQRCode(from dataString: String) -> UIImage? {
        let context = CIContext()
        let qrFilter = CIFilter.qrCodeGenerator()
        let data = Data(dataString.utf8)
        qrFilter.setValue(data, forKey: "inputMessage")
        
        if let outputImage = qrFilter.outputImage,
           let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
}
