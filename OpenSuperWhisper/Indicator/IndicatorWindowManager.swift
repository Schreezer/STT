import SwiftUI
import AppKit

class IndicatorWindowManager {
    static let shared = IndicatorWindowManager()
    
    var window: NSWindow?
    var viewModel: IndicatorViewModel?
    
    private init() {}
    
    func show(nearPoint point: NSPoint? = nil) -> IndicatorViewModel {
        // Create new view model
        let newViewModel = IndicatorViewModel()
        self.viewModel = newViewModel
        
        if window == nil {
            // Create window if it doesn't exist
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 200, height: 60),
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )
            
            window.level = .floating
            window.backgroundColor = .clear
            window.isOpaque = false
            window.hasShadow = false
            window.ignoresMouseEvents = true
            
            self.window = window
        }
        
        // Position window
        if let window = window, let screen = NSScreen.main {
            let windowFrame = window.frame
            let screenFrame = screen.frame
            
            var x: CGFloat
            var y: CGFloat
            
            if let point = point {
                // Position near cursor
                x = point.x - windowFrame.width / 2
                y = point.y + 20  // 20 points above cursor
            } else {
                // Default to top center of screen
                x = screenFrame.midX - windowFrame.width / 2
                y = screenFrame.maxY - windowFrame.height - 100 // 100 pixels from top
            }
            
            // Adjust if out of screen bounds
            x = max(screenFrame.minX, min(x, screenFrame.maxX - windowFrame.width))
            y = max(screenFrame.minY, min(y, screenFrame.maxY - windowFrame.height))
            
            window.setFrameOrigin(NSPoint(x: x, y: y))
            
            // Set content view
            let hostingView = NSHostingView(rootView: IndicatorWindow(viewModel: newViewModel))
            window.contentView = hostingView
        }
        
        window?.orderFront(nil)
        return newViewModel
    }
    
    func hide() {
        window?.orderOut(nil)
        viewModel = nil
    }
} 