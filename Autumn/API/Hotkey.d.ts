declare class Hotkey {

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
