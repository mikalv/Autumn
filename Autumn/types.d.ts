declare global {
    
    function loadFile(path: string): any;
    
    class Autumn {
        static quit(): void;
        static reloadConfigs(): void;
        static showDocs(): void;
        static showRepl(): void;
    }
    
    interface AlertOptions {
        duration?: number;
    }
    
    class Alert {
        static show(msg: string, options?: AlertOptions): void;
    }
    
    class Hotkey {
        
        constructor(options: { key: string; mods: {cmd?: boolean, ctrl?: boolean, alt?: boolean, shift?: boolean}; pressed?: () => void; released?: () => void; });
        
        enable(): boolean;
        disable(): void;
        
    }
    
    class Keyboard {
        
        static layoutChanged(callback: () => void): void;
        
    }
    
    class App {
        /**
         * Manipulate running applications.
         */
        
        /**
         * Returns an app object for the given pid.
         * @param pid process id of the app
         */
        static appForPid(pid: number): App;
        
        /**
         * Returns any running apps that have the given bundleID.
         * @param id Bundle ID, e.g. "com.apple.TextEdit"
         */
        static appsForBundleID(id: string): App[];
        
        /**
         * Returns all currently running apps.
         */
        static runningApps(): App[];
        
        /**
         * Launches the app with the given name, or activates it if it's already running.
         * Returns true if it launched or was already launched; otherwise false (presumably only if the app doesn't exist).
         * @param name Localized name of the app.
         */
        static open(name: string): boolean;
        
        /**
         * Checks whether this app object is the same as another.
         * @param app Another app object.
         */
        isEqual(app: App): boolean;
        
        /**
         * Returns the main window of the given app, or nil.
         */
        mainWindow(): Win;
        
        /**
         * Returns all open windows owned by the given app.
         */
        allWindows(): Win[];
        
        /**
         * Returns only the app's windows that are visible.
         */
        visibleWindows(): Win[];
        
        /**
         * True if the app has the spinny circle of death.
         */
        isUnresponsive(): boolean;
        
        /**
         * Returns the localized name of the app (in UTF8).
         */
        title(): string;
        
        /**
         * Returns the bundle identifier of the app.
         */
        bundleID(): string;
        
        /**
         * Unhides the app (and all its windows) if it's hidden.
         */
        unhide(): boolean;
        
        /**
         * Hides the app (and all its windows).
         */
        hide(): boolean;
        
        /**
         * Tries to terminate the app.
         */
        kill(): void;
        
        /**
         * Definitely terminates the app.
         */
        forceKill(): void;
        
        /**
         * Returns whether the app is currently hidden.
         */
        isHidden(): boolean;
        
        /**
         * Returns the app's process identifier.
         */
        pid(): number;
        
        /**
         * Returns the string 'dock' if the app is in the dock, 'no-dock' if not, and 'no-gui' if it can't even have GUI elements if it wanted to.
         */
        kind(): string;
        
        /**
         * Tries to activate the app (make its key window focused) and returns whether it succeeded.
         * @param allWindows Whether all windows are brought to the front.
         */
        activate(allWindows: boolean): boolean;
        
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
        static focusedWindow(): Win;
        
        /**
         * Returns handles to every window currently open in no specific order.
         */
        static allWindows(): Win[];
        
    }
    
}

export {
}
