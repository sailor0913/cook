//
//  ContentView.swift
//  cook
//
//  Created by ryp on 2023/9/2.
//

import SwiftUI

struct ContactView: View {
    let contact: Contact
    
    var body: some View {
        HStack {
            Text(contact.firstName ?? "--")
            Text(contact.lastName ?? "--")
            Spacer()
            Text(contact.phoneNumber ?? "--")
        }
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State private var isAddContactPresented = false
    @State private var seartchText: String = ""
    
    var body: some View {
        NavigationView {
            FilteredContact(filter: seartchText)
            .navigationTitle("Contacts")
            .toolbar {
                Button {
                    isAddContactPresented.toggle()
                } label: {
                    Image(systemName: "plus")
                }

            }
        }
        .sheet(isPresented: $isAddContactPresented) {
            AddNewContact(isAddContactPresented: $isAddContactPresented)
        }
        .searchable(text: $seartchText)
    }
}

struct AddNewContact: View {
    @EnvironmentObject var coreDataStack: CoreDataStack
    @Binding var isAddContactPresented: Bool
    @State var firstName = ""
    @State var lastName = ""
    @State var phoneNumber = ""
    
    var body: some View {
        NavigationView {
            VStack (spacing: 16) {
                TextField("First Name", text: $firstName)
                TextField("Last Name", text: $lastName)
                TextField("phoneNumber", text: $phoneNumber)
                    .keyboardType(.phonePad)
                Spacer()
            }
            .padding(16)
            .navigationTitle("Add a New Contact")
            .navigationBarItems(
                trailing:
                    Button(action: saveContact, label: {
                        Image(systemName: "checkmark")
                            .font(.headline)
                    })
                    .disabled(isDisabled)
            )
        }
    }
    
    private var isDisabled: Bool {
        firstName.isEmpty || lastName.isEmpty || phoneNumber.isEmpty
    }
    
    private func saveContact() {
        coreDataStack.insertContact(firstName: firstName, lastName: lastName, phoneNumber: phoneNumber)
        isAddContactPresented.toggle()
    }
}

struct FilteredContact: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    let fetchRequest: FetchRequest<Contact>
    
    init(filter: String) {
        let predicate: NSPredicate? = filter.isEmpty ? nil : NSPredicate(format: "lastName CONTAINS[CD] %@ OR firstName CONTAINS[CD] %@", filter, filter)
        fetchRequest = FetchRequest<Contact>(
            sortDescriptors: [
                        NSSortDescriptor(keyPath: \Contact.lastName, ascending: true),
                        NSSortDescriptor(keyPath: \Contact.firstName, ascending: true)
                    ],
            predicate: predicate
        )
    }
    
    var body: some View {
        List{
            ForEach(fetchRequest.wrappedValue, id: \.self) {
                ContactView(contact: $0)
            }
            .onDelete(perform: deleteContact)
        }
        .listStyle(.plain)
    }
    
    private func deleteContact(at offset: IndexSet) {
        guard let index = offset.first else { return }
        managedObjectContext.delete(fetchRequest.wrappedValue[index])
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
