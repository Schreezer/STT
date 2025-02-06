import AppKit
import Carbon
import Combine
import Foundation

class Settings: ObservableObject {
    @Published var recordingShortcut: KeyboardShortcut
    private var globalEventMonitor: Any?
    private var localEventMonitor: Any?
    var onShortcutTriggered: (() -> Void)?
    
    struct KeyboardShortcut: Codable {
        var keyCode: Int
        var modifiers: Int
        
        var description: String {
            var desc = ""
            if modifiers & Int(NSEvent.ModifierFlags.command.rawValue) != 0 { desc += "⌘" }
            if modifiers & Int(NSEvent.ModifierFlags.option.rawValue) != 0 { desc += "⌥" }
            if modifiers & Int(NSEvent.ModifierFlags.shift.rawValue) != 0 { desc += "⇧" }
            if modifiers & Int(NSEvent.ModifierFlags.control.rawValue) != 0 { desc += "⌃" }
            
            let key = KeyCodeHelper.keyCodeToString(keyCode)
            return desc + key
        }
    }
    
    init() {
        // Default shortcut: Command + Backtick
        self.recordingShortcut = KeyboardShortcut(
            keyCode: kVK_ANSI_Grave,
            modifiers: Int(NSEvent.ModifierFlags.command.rawValue)
        )
        loadSettings()
        setupShortcuts()
    }
    
    private func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: "recordingShortcut"),
           let shortcut = try? JSONDecoder().decode(KeyboardShortcut.self, from: data)
        {
            recordingShortcut = shortcut
        }
    }
    
    func saveSettings() {
        if let encoded = try? JSONEncoder().encode(recordingShortcut) {
            UserDefaults.standard.set(encoded, forKey: "recordingShortcut")
        }
        setupShortcuts()
    }
    
    private func setupShortcuts() {
        // Remove existing monitors if any
        if let existingMonitor = globalEventMonitor {
            NSEvent.removeMonitor(existingMonitor)
        }
        if let existingMonitor = localEventMonitor {
            NSEvent.removeMonitor(existingMonitor)
        }
        
        // Setup global monitor for when app is not active
        globalEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyEvent(event)
        }
        
        // Setup local monitor for when app is active
        localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if self?.handleKeyEvent(event) == true {
                return nil // Событие обработано, не передаем его дальше
            }
            return event // Событие не обработано, передаем дальше
        }
    }
    
    private func handleKeyEvent(_ event: NSEvent) -> Bool {
        let modifiers = Int(event.modifierFlags.rawValue)
        if event.keyCode == UInt16(recordingShortcut.keyCode) &&
            modifiers == recordingShortcut.modifiers {
            DispatchQueue.main.async { [weak self] in
                NSApp.activate(ignoringOtherApps: true)
                self?.onShortcutTriggered?()
            }
            return true
        }
        return false
    }
    
    deinit {
        if let monitor = globalEventMonitor {
            NSEvent.removeMonitor(monitor)
        }
        if let monitor = localEventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}

class KeyCodeHelper {
    static func keyCodeToString(_ keyCode: Int) -> String {
        switch keyCode {
        case kVK_ANSI_A: return "A"
        case kVK_ANSI_S: return "S"
        case kVK_ANSI_D: return "D"
        case kVK_ANSI_F: return "F"
        case kVK_ANSI_H: return "H"
        case kVK_ANSI_G: return "G"
        case kVK_ANSI_Z: return "Z"
        case kVK_ANSI_X: return "X"
        case kVK_ANSI_C: return "C"
        case kVK_ANSI_V: return "V"
        case kVK_ANSI_B: return "B"
        case kVK_ANSI_Q: return "Q"
        case kVK_ANSI_W: return "W"
        case kVK_ANSI_E: return "E"
        case kVK_ANSI_R: return "R"
        case kVK_ANSI_Y: return "Y"
        case kVK_ANSI_T: return "T"
        case kVK_ANSI_1: return "1"
        case kVK_ANSI_2: return "2"
        case kVK_ANSI_3: return "3"
        case kVK_ANSI_4: return "4"
        case kVK_ANSI_6: return "6"
        case kVK_ANSI_5: return "5"
        case kVK_ANSI_9: return "9"
        case kVK_ANSI_7: return "7"
        case kVK_ANSI_8: return "8"
        case kVK_ANSI_0: return "0"
        case kVK_ANSI_P: return "P"
        case kVK_ANSI_O: return "O"
        case kVK_ANSI_I: return "I"
        case kVK_ANSI_U: return "U"
        case kVK_ANSI_L: return "L"
        case kVK_ANSI_J: return "J"
        case kVK_ANSI_K: return "K"
        case kVK_ANSI_N: return "N"
        case kVK_ANSI_M: return "M"
        case kVK_ANSI_Grave: return "`"
        default: return "Unknown"
        }
    }
}
