//
//  NotesTableView.swift
//  FSNotes
//
//  Created by Oleksandr Glushchenko on 7/31/17.
//  Copyright © 2017 Oleksandr Glushchenko. All rights reserved.
//

import Cocoa

class NotesTableView: NSTableView, NSTableViewDataSource,
    NSTableViewDelegate {
    
    var noteList = [Note]()
    
    override func draw(_ dirtyRect: NSRect) {
        self.dataSource = self
        self.delegate = self
        super.draw(dirtyRect)
    }
    
    
    override func keyDown(with event: NSEvent) {
        
        // Remove note (cmd-delete)
        if (event.keyCode == 51 && event.modifierFlags.contains(.command)) {
            if (!noteList.indices.contains(selectedRow)) {
                return
            }
            
            let note = noteList[selectedRow]
            let alert = NSAlert.init()
            
            if note.name == nil {
                alert.messageText = "Are you sure you want to move the selected note to the trash?"
            }
            else {
                alert.messageText = "Are you sure you want to move \(note.name)\" to the trash?"
            }
            alert.informativeText = "This action cannot be undone."
            alert.addButton(withTitle: "Remove note")
            alert.addButton(withTitle: "Cancel")
            alert.beginSheetModal(for: self.window!) { (returnCode: NSModalResponse) -> Void in
                if returnCode == NSAlertFirstButtonReturn {
                    self.removeNote(note)
                }
            }
        }
        
        // Note edit mode and select file name (cmd-R)
        if (event.keyCode == 15 && event.modifierFlags.contains(.command)) {
            let row = rowView(atRow: selectedRow, makeIfNecessary: false) as! NoteRowView
            let cell = row.view(atColumn: 0) as! NoteCellView
            
            cell.name.isEditable = true
            cell.name.becomeFirstResponder()
            
            let fileName = cell.name.currentEditor()!.string! as NSString
            let fileNameLength = fileName.length - fileName.pathExtension.characters.count - 1
            
            cell.name.currentEditor()?.selectedRange = NSMakeRange(0, fileNameLength)
        }
        
        super.keyDown(with: event)
    }
        
    override func keyUp(with event: NSEvent) {
        // Tab
        if (event.keyCode == 48) {
            let viewController = self.window?.contentViewController as? ViewController
            viewController?.focusEditArea()
        }
        
        super.keyUp(with: event)
    }
    
    func removeNote(_ note: Note) {
        note.remove()
        
        let viewController = self.window?.contentViewController as! ViewController
        viewController.editArea.string = ""
        viewController.updateTable(filter: "")
        
        // select next note if exist
        let nextRow = selectedRow
        if (noteList.indices.contains(nextRow)) {
            self.selectRowIndexes([nextRow], byExtendingSelection: false)
        }
    }
    
    // Custom note highlight style
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return NoteRowView()
    }
    
    // Populate table data
    func numberOfRows(in tableView: NSTableView) -> Int {
        return noteList.count
    }
    
    // On selected row show notes in right panel
    func tableViewSelectionDidChange(_ notification: Notification) {
        let viewController = self.window?.contentViewController as? ViewController
        
        if (noteList.indices.contains(selectedRow)) {
            viewController?.editArea.fill(note: noteList[selectedRow])
        }
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return noteList[row]
    }
    
    func getNoteFromSelectedRow() -> Note {
        var note = Note()
        var selected = self.selectedRow
        
        if (selected < 0) {
            selected = 0
        }
        
        if (noteList.indices.contains(selected)) {
            let viewController = self.window?.contentViewController as! ViewController
            let id = noteList[selected].id
            note = viewController.storage.noteList[id]
        }
        
        return note
    }
}
