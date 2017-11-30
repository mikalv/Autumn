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
declare class Win {

  /**
  * Returns the window that currently has focus.
  */
  static focusedWindow(): Win;

  /**
  * Returns handles to every window currently open in no specific order.
  */
  static allWindows(): Win[];

}
