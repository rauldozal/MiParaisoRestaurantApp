//
//  ContentView.swift
//  Mi Paraiso Restaurant
//
//  Created by Raul Dozal on 5/31/26.
//

import SwiftUI

struct ContentView: View {
    // Defining all variables
    let foodItems = [
        MenuItem(iconName: "fork.knife", itemName: "Taco Plate", price: 12),
        MenuItem(iconName: "fork.knife", itemName: "Enchilada Plate", price: 12),
        MenuItem(iconName: "fork.knife", itemName: "Fajita Plate", price: 15)
    ]
    
    let drinkItems = [
        MenuItem(iconName: "mug.fill", itemName: "Lemonade", price: 5),
        MenuItem(iconName: "mug.fill", itemName: "Water Bottle", price: 2.5),
        MenuItem(iconName: "mug.fill", itemName: "Water", price: 0)
    ]
    
    var allItems: [MenuItem] {
        foodItems + drinkItems
    }
    
    // using a dictionary to store [itemName: quantity]
    @State var quantities: [String: Int] = [:]
    @State var tip: Int = 0
    
    var subtotal: Double {
        // collection.reduce(initialValue) { runningValue, currentItem in
        //  return updatedRunningValue
        // }
        allItems.reduce(0) { runningTotal, item in
            let quantity = quantities[item.itemName] ?? 0
            return runningTotal + (item.price * Double(quantity))
        }
    }
    var tipAmount: Double {
        subtotal * Double(tip)/100
    }
    var total: Double {
        subtotal + tipAmount
    }
    
    // Starting the body of the ContentView
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Category(category: "Food")
                    ForEach(foodItems, id: \.itemName) { item in
                        ListItem(iconName: item.iconName,
                                 itemName: item.itemName,
                                 price: item.price,
                                 quantities: $quantities)
                    }
                }
                Section {
                    Category(category: "Drinks")
                    ForEach(drinkItems, id: \.itemName) { item in
                        ListItem(iconName: item.iconName,
                                 itemName: item.itemName,
                                 price: item.price,
                                 quantities: $quantities)
                    }
                }
                Section {
                    if quantities.isEmpty {
                        Text("No items selected")
                    } else {
                        PrintQuantities(allItems: allItems, quantities: quantities)
                    }
                }
                Section {
                    TipItemPicker(tip: $tip)
                }
                Section {
                    HStack {
                        Text("Subtotal")
                            .fontWeight(.bold)
                        Spacer()
                        Text(String(format: "$%.2f", subtotal))
                            .fontWeight(.bold)
                    }
                    HStack {
                        Text("Tip")
                            .fontWeight(.bold)
                        Spacer()
                        Text(String(format: "$%.2f", tipAmount))
                            .fontWeight(.bold)
                    }
                    HStack {
                        Text("Total")
                            .fontWeight(.bold)
                        Spacer()
                        Text(String(format: "$%.2f", total))
                            .fontWeight(.bold)
                    }
                }
                Section {
                    ConfirmOrder(allItems: allItems, quantities: quantities, total: total)
                }
            }
            .listStyle(GroupedListStyle())
            .navigationTitle(Text("Checkout"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct TipItemPicker: View {
    // @State property wrapper moves variable storage outside of the struct and gives control to Swift UI
    @State var flag: Bool = false
    @Binding var tip: Int
    var tipOptions: [Int] = [0, 5, 10, 15, 20, 25]
    var body: some View {
        VStack {
            Toggle("Add a Tip?", isOn: $flag.animation())
            if flag {
                Picker("Tip Percentage", selection: $tip) {
                    ForEach(tipOptions, id: \.self) { option in
                        Text("\(option)%")
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
            }
        }
        .onChange(of: flag) {
            if flag == false {
                tip = 0
            }
        }
    }
}

struct ConfirmOrder: View {
    // @State property wrapper moves variable storage outside of the struct and gives control to Swift UI
    @State var present: Bool = false
    var allItems: [MenuItem]
    var quantities: [String: Int]
    var total: Double
    
    var body: some View {
        Button("Confirm Order") {
            present = true
        }
        .disabled(quantities.isEmpty)
        .sheet(isPresented: $present, content: {
            VStack(spacing: 20) {
                Image("launch")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                SecondView(present: $present,
                           allItems: allItems,
                           quantities: quantities,
                           total: total)
            }
            .padding()
        })
    }
}

struct SecondView: View {
    @Binding var present: Bool
    var allItems: [MenuItem]
    var quantities: [String: Int]
    var total: Double
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Order Confirmed!")
                .font(.title2)
                .fontWeight(.bold)
            
            PrintQuantities(allItems: allItems, quantities: quantities)
            
            Text(String(format: "Total: $%.2f", total))
                .font(.title3)
                .fontWeight(.bold)
            Button("Dismiss") {
                present = false
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

struct PrintQuantities: View {
    var allItems: [MenuItem]
    var quantities: [String: Int]
    
    var body: some View {
        VStack(spacing: 15) {
            // keys are the item names
            ForEach(quantities.keys.sorted(), id: \.self) { itemName in
                // print only if quantity and item exist
                if let quantity = quantities[itemName],
                   let item = allItems.first(where: { $0.itemName == itemName}) {
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text(itemName)
                                .fontWeight(.medium)
                            Text("Qty: \(quantity)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(String(format: "$%.2f", item.price * Double(quantity)))
                            .fontWeight(.bold)
                    }
                }
            }
        }
    }
}

struct ListItem: View {
    
    var iconName: String = "globe"
    var itemName: String
    var price: Double
    
    @Binding var quantities: [String: Int]
    
    var currentQuantity: Int {
        quantities[itemName] ?? 0
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: currentQuantity > 0 ? "checkmark.circle.fill" : iconName)
                    .imageScale(.large)
                Text(itemName)
                Spacer()
                Text(String(format: "$%.2f",price))
            }
            if currentQuantity > 0 {
                HStack {
                    // Stepper(label, value: binding, in: range) is the new UI element or feature I explored.
                    Stepper("Qty: \(currentQuantity)",
                            value: Binding(
                                get: {
                                    quantities[itemName] ?? 0
                                },
                                set: { newQty in
                                    if newQty == 0 {
                                        quantities.removeValue(forKey: itemName)
                                    } else {
                                        quantities[itemName] = newQty
                                    }
                                }
                            ),
                            in: 0...10)
                    Spacer()
                }
                .padding(.top, 5)
            }
        }
        .padding()
        .foregroundStyle(Color("theme"))
        .contentShape(Rectangle())
        .onTapGesture {
            if currentQuantity == 0 {
                quantities[itemName] = 1
            } else {
                quantities.removeValue(forKey: itemName)
            }
        }
    }
}

struct MenuItem {
    var iconName: String
    var itemName: String
    var price: Double
}

struct Category: View {
    var category: String
    var body: some View {
        HStack {
            Text(category)
                .font(.title3)
                .fontWeight(.bold)
        }
        .padding()
    }
}

//Creates a preview tab in the canvas
#Preview {
    ContentView()
        .preferredColorScheme(.light)
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
