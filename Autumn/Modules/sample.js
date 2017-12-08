// @ts-check

const { Cmd, Ctrl, Shift, Alt, Opt } = Autumn.Hotkey;

const mash = Cmd | Alt | Ctrl;

Autumn.Hotkey.create(mash, 'r', () => {
  // Autumn.Core.showRepl();
  Autumn.Core.reloadConfigs();
});

Autumn.Alert.show('Config loaded.');
