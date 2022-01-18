
import SwiftUI

struct EditView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var deckToEdit: MTGDeck?
    
    @State var name: String = ""
    @State var colours: MTGColours = MTGColours.none
    @State var tags: Set<String> = []
    @State var contents: String = ""
    
    @State var shareSheetShown: Bool = false
    
    var body: some View {
        Form {
            if deckToEdit == nil {
                ProgressView().padding()
                Text("Loading...")
            } else {
                Section() {
                    TextField(name, text: $name)
                    HStack {
                        MTGColorPickerView(selectedColours: $colours)
                    }
                    HStack {
                        ForEach(tags.sorted(by: <), id: \.self) { tag in
                            HStack {
                                Text(tag)
                                Button(action: {
                                    removeTag(tag)
                                }) {
                                    Image(systemName: "x.circle.fill")
                                }
                            }
                            .padding(.leading, 10)
                            .padding(.trailing, 4)
                            .padding(.vertical, 2)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .background(Color(.secondarySystemFill))
                            .clipShape(Capsule())
                        }
                        Button(action: {
                            // TODO
                        }) {
                            Image(systemName: "plus.circle")
                                .font(.title2)
                        }
                    }
                }
                TextEditor(text: $contents)
                    .frame(height: 400)
                Section {
                    Button(action: {
                        deckToEdit!.name = name
                        deckToEdit!.colors = colours
                        deckToEdit!.tags = tags
                        deckToEdit!.contents = contents
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Save")
                    }
                    Button(action: {
                        shareSheetShown = true
                    }) {
                        Text("Share")
                    }
                    Button(action: {
                        deckToEdit = nil
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancel")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .sheet(isPresented: $shareSheetShown) {
            ShareSheet(activityItems: [contents])
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear(perform: {
            name = deckToEdit!.name
            colours = deckToEdit!.colors
            tags = deckToEdit!.tags
            contents = deckToEdit!.contents
        })
    }
    
    func addTag(_ tag: String) {
        
    }
    
    func removeTag(_ tag: String) {
        
    }
}
