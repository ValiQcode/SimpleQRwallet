import SwiftUI
import CoreData

struct AddCardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    @State private var label: String = ""
    @State private var data: String = ""
    @State private var selectedType: String = "QRCode"  // Default selection

    // Updated types array to include "QRCode," "DataMatrix," and "EAN13"
    let types = ["QRCode", "DataMatrix", "EAN13"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Label")) {
                    TextField("Enter label", text: $label)
                }
                Section(header: Text("Data")) {
                    TextField("Enter data", text: $data)
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
        do {
            try viewContext.save()
        } catch {
            print("Error saving new card: \(error.localizedDescription)")
        }
    }
}
