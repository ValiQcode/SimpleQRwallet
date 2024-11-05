import SwiftUI
import CoreData

struct AddCardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    @State private var label: String = ""
    @State private var data: String = ""
    @State private var selectedType: String = "QRCode"
    
    // Updated types array to include "UPC"
    let types = ["QRCode", "Barcode", "UPC", "EAN13"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Label")) {
                    TextField("Enter label", text: $label)
                }
                Section(header: Text("Data")) {
                    TextField("Enter data", text: $data)
                        .keyboardType(.numberPad) // Ensures numeric input for UPC if needed
                }
                Section(header: Text("Type")) {
                    Picker("Type", selection: $selectedType) {
                        ForEach(types, id: \.self) { type in
                            Text(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationBarTitle("Add QR Card")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                addCard()
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    private func addCard() {
        let newCard = QRCard(context: viewContext)
        newCard.id = UUID()
        newCard.label = label
        newCard.data = data
        newCard.type = selectedType
        try? viewContext.save()
    }
}
