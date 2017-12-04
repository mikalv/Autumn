declare namespace Autumn {

    function quit(): void;

    /**
     * This also resets the JS VM and removes all callbacks.
     */
    function reloadConfigs(): void;
    function showDocs(): void;
    function showRepl(): void;
    function loadFile(path: string): any;

    /**
     * Show brief, highly visible messages in the center of your screen.
     */
    class Alert {

        static show(
            msg: string,
            options?: {
                duration?: number;
            }
        ): void;

    }

    /**
     * Create custom global keyboard shortcuts.
     */
    class Hotkey {

        constructor(options: {
            key: string;
            mods: {
                cmd?: boolean,
                ctrl?: boolean,
                alt?: boolean,
                shift?: boolean
            };
            pressed?: () => void;
            released?: () => void;
        });

        enable(): boolean;
        disable(): void;

        equals(other: Hotkey): boolean;

    }

    class Keyboard {

        /**
         * This replaces the previous callback.
         */
        static setLayoutChangedCallback(fn: () => void): void;

    }

    /**
     * Manipulate running applications.
     */

    class App {
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
        mainWindow(): Window;

        /**
         * Returns all open windows owned by the given app.
         */
        allWindows(): Window[];

        /**
         * Returns only the app's windows that are visible.
         */
        visibleWindows(): Window[];

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

    class Point {
        x: number;
        y: number;
    }

    class Size {
        width: number;
        height: number;
    }

    class Rect {
        x: number;
        y: number;
        width: number;
        height: number;
    }

    /**
     * Functions for managing any open window.
     */
    class Window {

        static focusedWindow(): Window;

        static allWindows(): Window[];
        static visibleWindows(): Window[];
        static orderedWindows(): Window[];

        static windowForID(id: number): Window;
        windowID(): number;

        otherWindows(allScreens: boolean): Window[];

        equals(other: Window): boolean;

        title(): string;
        subrole(): string;
        role(): string;

        app(): App;

        isStandardWindow(): boolean;
        isFullScreen(): boolean;
        isMinimized(): boolean;
        isVisible(): boolean;

        topLeft(): Point;
        size(): Size;
        frame(): Rect;

        setTopLeft(thePoint: Point): void;
        setSize(theSize: Size): void;
        setFrame(frame: Rect): void;

        moveToPercentOfScreen(unit: Rect): void;

        close(): void;
        setFullScreen(shouldBeFullScreen: boolean): void;
        minimize(): void;
        unminimize(): void;
        maximize(): void;

        becomeMain(): void;
        focus(): void;

        screen(): Screen;

        windowsToEast(): Window[];
        windowsToNorth(): Window[];
        windowsToWest(): Window[];
        windowsToSouth(): Window[];

        focusFiristWindowToEast(): void;
        focusFiristWindowToNorth(): void;
        focusFiristWindowToWest(): void;
        focusFiristWindowToSouth(): void;

    }

    class Screen {

        allScreens(): Screen[];
        focusedScreen(): Screen;

        equals(other: Screen): boolean;

        screenId(): number;
        name(): string;

        fullFrame(): Rect;
        frame(): Rect;

        nextScreen(): Screen;
        previousScreen(): Screen;

        screenToEast(): Screen;
        screenToNorth(): Screen;
        screenToWest(): Screen;
        screenToSouth(): Screen;

    }

}
