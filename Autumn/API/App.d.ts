/**
* Manipulate running applications.
*/

declare class App {
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
