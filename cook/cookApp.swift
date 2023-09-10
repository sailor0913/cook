//
//  cookApp.swift
//  cook
//
//  Created by ryp on 2023/9/2.
//

import SwiftUI

@main
struct cookApp: App {
    @Environment(\.scenePhase) var scenePhase
    
    private let coreDataStack = CoreDataStack(modelName: "ContactsModel")
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(coreDataStack)
                .environment(\.managedObjectContext, coreDataStack.managedObjectContext)
                .onChange(of: scenePhase) { _ in
                    coreDataStack.save()
                }
                .onAppear{
                    addContacts(to: coreDataStack)
                }
        }
    }
}
