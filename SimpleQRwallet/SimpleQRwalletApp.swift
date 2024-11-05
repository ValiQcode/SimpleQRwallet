import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \QRCard.label, ascending: true)],
        animation: .default)
    private var qrCards: FetchedResults<QRCard>

    @State private var showAddCardView = false
    @State private var selectedCard: QRCard? = nil

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
                .onDelete(perform: deleteCards) // Enable swipe-to-delete
            }
            .navigationBarTitle("QR Wallet")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddCardView = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddCardView) {
                AddCardView()
            }
            .sheet(item: $selectedCard) { card in
                QRCardDetailView(card: card) // Show details in a pop-up sheet
            }
        }
    }

    private func deleteCards(at offsets: IndexSet) {
        offsets.map { qrCards[$0] }.forEach(viewContext.delete)
        do {
            try viewContext.save() // Save context to persist deletion
        } catch {
            print("Error deleting card: \(error.localizedDescription)")
        }
    }
}

// Detail View for Displaying Selected Card Data
import CoreImage.CIFilterBuiltins

struct QRCardDetailView: View {
    let card: QRCard
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Text(card.label ?? "No Label")
                .font(.largeTitle)
                .padding()

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

            // Delete button
            Button(action: deleteCard) {
                Text("Delete Card")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(8)
            }
            .padding()

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
            return drawEAN13Barcode(from: card.data ?? "")
        case "DataMatrix":
            return generateDataMatrix(from: card.data ?? "") // Call Data Matrix generator
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

    private func deleteCard() {
        viewContext.delete(card)
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss() // Close the view after deletion
        } catch {
            print("Error deleting card: \(error.localizedDescription)")
        }
    }
}
