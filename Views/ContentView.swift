
import SwiftUI

extension MTGColours {
    var visibleColor: Color {
        if (self.isSubset(of: MTGColours.white)) {
            return .yellow
        } else if (self.isSubset(of: MTGColours.blue)) {
            return .blue
        } else if (self.isSubset(of: MTGColours.black)) {
            return .gray
        } else if (self.isSubset(of: MTGColours.red)) {
            return .red
        } else if (self.isSubset(of: MTGColours.green)) {
            return .green
        } else if (self.isSubset(of: MTGColours.colourless)) {
            return .white
        } else {
            return .brown
        }
    }
}

struct MTGColourView: View {
    let color: Color
    let selected: Bool
    
    var body: some View {
        if (selected) {
            Circle()
                .fill(color)
                .frame(width: 22, height: 22)
        } else {
            Circle()
                .strokeBorder(color, lineWidth: 2)
                .frame(width: 22, height: 22)
        }
    }
}

struct MTGColorView: View {
    let colours: MTGColours
    
    var body: some View {
        ForEach([
            MTGColours.white,
            MTGColours.blue,
            MTGColours.black,
            MTGColours.red,
            MTGColours.green,
            MTGColours.colourless
        ], id: \.self) { item in
            MTGColourView(
                color: item.visibleColor,
                selected: colours.contains(item))
        }
    }
}

struct MTGColorPickerView: View {
    @Binding var selectedColours: MTGColours
    
    var body: some View {
        ForEach([
            MTGColours.white,
            MTGColours.blue,
            MTGColours.black,
            MTGColours.red,
            MTGColours.green,
            MTGColours.colourless
        ], id: \.self) { item in
            Button(action: {
                if (selectedColours.contains(item)) {
                    selectedColours.remove(item)
                } else {
                    selectedColours.update(with: item)
                }
            }) { MTGColourView(
                color: item.visibleColor,
                selected: selectedColours.contains(item)
            ) }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct ContentView: View {
    
    @Environment(\.colorScheme) var colorScheme

    @State private var deckManager: MTGDeckManager? = nil
    
    @State private var showFilters: Bool = false
    @State var filteredTags: Set<String> = []
    @State var filteredColours: MTGColours = MTGColours.none
    
    @State var shareSheetShown: Bool = false
    
    @State var editSheetShown: Bool = false
    @State var deckToEdit: MTGDeck? = nil

    @State var deleteConfirmationShown: Bool = false
    @State var deckToDelete: MTGDeck? = nil
    
    var filteredDecks: [MTGDeck] {
        guard let deckManager = deckManager else {
            return []
        }

        if (!showFilters) {
            return deckManager.decks
        }
        return deckManager.decks.filter { deck in
            deck.tags.isSuperset(of: filteredTags) &&
            deck.colors.isSuperset(of: filteredColours)
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                if deckManager == nil {
                    ProgressView().padding()
                    Text("Loading...")
                } else {
                    HStack {
                        Button(action: {
                            filteredColours = MTGColours.none
                            filteredTags = []
                            showFilters = !showFilters
                        }) {
                            if (showFilters) {
                                Image(systemName: "line.3.horizontal.decrease.circle.fill")
                                    .font(.title2)
                            } else {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                    .font(.title2)
                            }
                        }
                        Text("Decks")
                            .fontWeight(.semibold)
                            .font(.title)
                        Spacer()
                        Button(action: {
                            shareSheetShown = true
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title2)
                        }
                        Spacer().frame(width: 14)
                        Button(action: importFromClipboad) {
                            Image(systemName: "plus.circle")
                                .font(.title2)
                        }
                        Spacer().frame(width: 4)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 12, alignment: .trailing)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 10)
                    if (showFilters) {
                        HStack {
                            Spacer().frame(width: 12)
                            ForEach(deckManager!.tags.sorted(by: <), id: \.self) { tag in
                                if filteredTags.contains(tag) {
                                    Button(action: {
                                        filteredTags.remove(tag)
                                    }) {
                                        Text(tag)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 2)
                                    .foregroundColor(colorScheme == .dark ? .black : .white)
                                    .background(colorScheme == .dark ? .white : .black)
                                    .clipShape(Capsule())
                                } else {
                                    Button(action: {
                                        filteredTags.insert(tag)
                                    }) {
                                        Text(tag)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 2)
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                    .background(Color(.secondarySystemFill))
                                    .clipShape(Capsule())
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: 14, alignment: .leading)
                        HStack {
                            Spacer().frame(width: 4)
                            MTGColorPickerView(selectedColours: $filteredColours)
                            Button(action: {
                                filteredColours = MTGColours.none
                            }) {
                                Image(systemName: "xmark.circle")
                                    .font(.title2)
                            }
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: 12, alignment: .leading)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                    }
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 8) {
                            ForEach(filteredDecks, id: \.self) { deck in
                                HStack {
                                    Button(action: {
                                        deckToEdit = deck
                                        editSheetShown = true
                                    }) {
                                        MTGColorView(colours: deck.colors)
                                        Spacer().frame(width: 14)
                                        Text(deck.name)
                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                        Spacer()
                                        Button(action: {
                                            deckToDelete = deck
                                            deleteConfirmationShown = true
                                        }) {
                                            Image(systemName: "minus.circle")
                                                .font(.title2)
                                                .padding(.leading, 2)
                                                .foregroundColor(.red)
                                        }
                                    }
                                }.padding(.vertical, 4)
                            }
                        }.padding()
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $editSheetShown, onDismiss: {
            if (deckToEdit != nil) {
                addOrReplace(deckToEdit!)
            }
            deckToEdit = nil
        }, content: {
            EditView(deckToEdit: $deckToEdit)
        })
        .sheet(isPresented: $shareSheetShown) {
            ShareSheet(activityItems: [MTGDeckManager.cachePath])
        }
        .alert("Delete \(deckToDelete != nil ? deckToDelete!.name : "Unknown")?", isPresented: $deleteConfirmationShown) {
            Button("Delete", role: .destructive, action: {
                delete(deckToDelete!)
                deckToDelete = nil
            })
            Button("Cancel", role: .cancel, action: {
                deckToDelete = nil
            })
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top)
        .onAppear(perform: {
            deckManager = MTGDeckManager.load()
            if (deckManager == nil) {
                deckManager = MTGDeckManager(decks: [])
            }
            deckManager!.save()
        })
    }
    
    func importFromClipboad() {
        if (UIPasteboard.general.hasStrings) {
            guard let contents = UIPasteboard.general.string else { return }
            deckToEdit = MTGDeck(id: deckManager!.nextId, name: "", colors: MTGColours.none, contents: contents, tags: [])
            editSheetShown = true
        }
    }
    
    func addOrReplace(_ addedDeck: MTGDeck) {
        var wasDeckModified = false
        deckManager!.decks = deckManager!.decks.map { deck in
            if (deck.id == addedDeck.id) {
                wasDeckModified = true
                return addedDeck
            } else {
                return deck
            }
        }
        if !wasDeckModified {
            deckManager!.decks.append(addedDeck)
        }
        deckManager!.save()
    }
    
    func delete(_ deletedDeck: MTGDeck) {
        deckManager!.decks = deckManager!.decks.filter { deck in
            deck.id != deletedDeck.id
        }
        deckManager!.save()
    }
}
