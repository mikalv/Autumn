declare global {
    
    class Alert {
        static show(msg: string): void;
    }
    
    interface HotkeyModifiers {
        cmd?:   boolean;
        ctrl?:  boolean;
        alt?:   boolean;
        shift?: boolean;
    }
    
    interface HotkeyOptions {
    key: string;
    mods: HotkeyModifiers;
        pressed?: () => void;
        released?: () => void;
    }
    
    class Hotkey {
        
        constructor(options: HotkeyOptions): Hotkey;
        
        enable(): boolean;
        disable(): void;
        
    }
    
    class App {
        /**
         * Manipulate running applications.
         */
        
        /**
         * Returns an app object for the given pid.
         * @param pid process id of the app
         */
        static appForPid(pid: number): App { return null; }
        
        /**
         * Returns any running apps that have the given bundleID.
         * @param id Bundle ID, e.g. "com.apple.TextEdit"
         */
        static appsForBundleID(id: string): [App] { return null; }
        
        /**
         * Returns all currently running apps.
         */
        static runningApps(): [App] { return null; }
        
        /**
         * Checks whether this app object is the same as another.
         * @param app Another app object.
         */
        isEqual(app: App): boolean { return null; }
        
        /**
         * Returns the main window of the given app, or nil.
         */
        mainWindow(): Win { return null; }
        
        /**
         * Returns all open windows owned by the given app.
         */
        allWindows(): [Win] { return null; }
        
        /**
         * Returns only the app's windows that are visible.
         */
        visibleWindows(): [Win] { return null; }
        
        /**
         * True if the app has the spinny circle of death.
         */
        isUnresponsive(): boolean { return null; }
        
        /**
         * Returns the localized name of the app (in UTF8).
         */
        title(): string { return null; }
        
        /**
         * Returns the bundle identifier of the app.
         */
        bundleID(): string { return null; }
        
        /**
         * Unhides the app (and all its windows) if it's hidden.
         */
        unhide(): boolean { return null; }
        
        /**
         * Hides the app (and all its windows).
         */
        hide(): boolean { return null; }
        
        /**
         * Tries to terminate the app.
         */
        kill() { return null; }
        
        /**
         * Definitely terminates the app.
         */
        forceKill() { return null; }
        
        /**
         * Returns whether the app is currently hidden.
         */
        isHidden(): boolean { return null; }
        
        /**
         * Returns the app's process identifier.
         */
        pid(): number { return null; }
        
        /**
         * Returns the string 'dock' if the app is in the dock, 'no-dock' if not, and 'no-gui' if it can't even have GUI elements if it wanted to.
         */
        kind(): string { return null; }
        
        /**
         * Launches the app with the given name, or activates it if it's already running.
         * Returns true if it launched or was already launched; otherwise false (presumably only if the app doesn't exist).
         * @param name Localized name of the app.
         */
        launchOrFocus(name: string): boolean { return null; }
        
        /**
         * Tries to activate the app (make its key window focused) and returns whether it succeeded.
         * @param allWindows Whether all windows are brought to the front.
         */
        activate(allWindows: boolean): boolean { return null; }
        
    }
    
    class Win {
        /**
         * Functions for managing any window.
         *
         * To get windows, see `Window.focusedWindow` and `Window.visibleWindows`.
         *
         * To get window geometrical attributes, see `Window.{frame,size,topleft}`.
         *
         * To move and resize windows, see `Window.set{frame,size,topleft}`.
         *
         * It may be handy to get a window's app or screen via `Window.app` and `Window.screen`.
         *
         * See the `Screen` class for detailed explanation of how Mjolnir uses window/screen coordinates.
         */
        
        /**
         * Returns the window that currently has focus.
         */
        static focusedWindow(): Win { return null; }
        
        /**
         * Returns handles to every window currently open in no specific order.
         */
        static allWindows(): [Win] { return null; }
        
    }
    
}

export {
}
