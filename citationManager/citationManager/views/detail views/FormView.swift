//
//  FormView.swift
//  Citer
//
//  Created by Jort Boxelaar on 23/02/2024.
//

import SwiftUI
import SwiftData

struct FormView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    @Query var papers: [Paper]
    
    @State private var titleText: String = ""
    @State private var authorText: String = ""
    @State private var yearText: String = ""
    @State private var urlText: String = ""
    @State private var abstractText: String = ""
    
    @State private var bibcodeText: String = ""
    @State private var submitted: Bool = false
    @State private var bibcodeExists: Bool = false
    @State private var isInt: Bool = true
    @State private var fileAdded: Bool = false
    
    @State private var filePath: URL? = nil
    
    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    
    var body: some View {
        Spacer()
        VStack {
            HStack(alignment: .top) {
                Spacer()
                Form {
                    Spacer()
                    
                    TextField("Title*", text: $titleText)
                    if submitted && titleText.isEmpty { Text("Enter a Title").foregroundStyle(.red) }
                    
                    TextField("Year*", text: $yearText)
                    if submitted && yearText.isEmpty { Text("Enter a Year").foregroundStyle(.red) }
                    else if submitted && !isInt { Text("Year Invalid").foregroundStyle(.red) }
                    
                    TextField("Authors (';' seperated)*", text: $authorText)
                    if submitted && authorText.isEmpty { Text("Enter an Author").foregroundStyle(.red) }
                    
                    TextField("Absract", text: $abstractText)
                    TextField("Webpage Url", text: $urlText)
                    Text("* Required")
                    
                    Spacer()
                    
                    if submitted && bibcodeText.isEmpty { Text("Generate an Identifier").foregroundStyle(.red) }
                    else if submitted && bibcodeExists { Text("Identifieer Already Exists").foregroundStyle(.red) }
                    TextField("Unique identifier*", text: $bibcodeText)
                    Button(action: {
                        bibcodeText = randomString(length: 10)
                    }, label: {
                        Label("Generate", systemImage: "arrow.circlepath")
                    }).frame(alignment: .trailing)
                    
                    Spacer()
                    
                    Button(action: {
                        filePath = filePicker()
                    }, label: {
                        Label("Add Document", systemImage: "doc.badge.plus")
                    })
                    if filePath != nil {
                        Text(filePath!.path.split(separator: "/").last!)
                            .foregroundStyle(.red)
                    }
            
                }
                Spacer()
            }
            Spacer()
            
            HStack {
                Button("Cancel") {
                    resetValues()
                    dismiss()
                }
                    .keyboardShortcut(.cancelAction)
                    .padding(.vertical)
                
                Button("Submit") {
                    if Int(yearText) != nil {
                        isInt = true
                    } else {
                        submitted = true
                        isInt = false
                    }
                    
                    if titleText.isEmpty || yearText.isEmpty || authorText.isEmpty || bibcodeText.isEmpty {
                        submitted = true
                        
                    } else if papers.map({$0.bibcode}).contains(bibcodeText) {
                        submitted = true
                        bibcodeExists = true
                        
                    } else {
                        bibcodeExists = false
                    }
                        
                        
                    if isInt && !bibcodeExists {
                        let authors = authorText.split(separator: ";").map({Author(name: String($0))})
                        let toPath: String = "\(documentsPath)/" + bibcodeText + ".pdf"
                        
                        if filePath != nil {
                            copyDocument(file: filePath!, toFile: URL(filePath: toPath))
                        }
                        
                        let paper = Paper(bibcode: bibcodeText,
                                          title: titleText,
                                          abstract: abstractText,
                                          webLink: urlText,
                                          docLink: toPath,
                                          authors: authors,
                                          arXivId: "",
                                          doi: "",
                                          year: yearText)
                        
                        context.insert(paper)
                        
                        resetValues()
                        dismiss()
                    }
                }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.defaultAction)
                    .padding(.vertical)
            }
        }
    }
    
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func resetValues() {
        titleText = ""
        authorText = ""
        yearText = ""
        urlText = ""
        abstractText = ""
        
        bibcodeText = ""
        submitted = false
        bibcodeExists = false
        isInt = true
        fileAdded = false
        
        filePath = nil
    }
}

func filePicker() -> URL? {
    let dialog = NSOpenPanel()
    
    dialog.title = "Choose a file"
    dialog.showsResizeIndicator = true
    dialog.showsHiddenFiles = false
    dialog.allowsMultipleSelection = false
    dialog.canChooseDirectories = false
    dialog.allowedContentTypes = [.pdf]

    if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
        let result = dialog.url // Pathname of the file

        if (result != nil) {
            let path: String = result!.path
            print(path)
            return result!
            
            // path contains the file path e.g
            // /Users/ourcodeworld/Desktop/file.txt
        } else { return nil }
        
    } else {
        // User clicked on "Cancel"
        return nil
    }
}

func copyDocument(file fromFile: URL, toFile: URL) {
    do {
        if FileManager.default.fileExists(atPath: toFile.path) {
            try FileManager.default.removeItem(at: toFile)
        }
        try FileManager.default.copyItem(at: fromFile, to: toFile)
    }
    catch {
        print("Copying error: \(error)")
    }
}


