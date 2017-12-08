# AutumnJS.app

*macOS Automation for Power Users*

---

Benefits over other macOS window managers:

* Uses JavaScript for configuration
* Intuitive and not-over-complicated API
* IDE autocompletion and documentation available via TypeScript `.d.ts` file
* Stable API

[Full API documentation](http://sdegutis.github.io/Autumn/)

Examples:
~~~javascript

// @ts-check

const { Cmd, Ctrl, Shift, Alt, Opt } = Autumn.Hotkey;

const mash = Cmd | Alt | Ctrl;

Autumn.Hotkey.create(mash, 'r', () => {
  Autumn.Core.reloadConfigs();
  Autumn.Core.showRepl();
});

Autumn.Hotkey.create(mash, 'd', () => {
  Autumn.App.open('Dictionary');
  Autumn.Alert.show('Opening dictionary...');
});

Autumn.Alert.show('Config reloaded.');

console.log('config has loaded!');
~~~

### Cool stuff, right?

I meticulously crafted AutumnJS.app after years of experience writing
window managers for macOS. My previous work includes **Hydra**,
**Phoenix**, **Mjolnir**, and **Zephyros**.

[Donate via PayPal.](https://www.paypal.com/cgi-bin/webscr?business=sbdegutis@gmail.com&cmd=_donations&item_name=AutumnJS.app%20donation&no_shipping=1)

### License

Copyright 2017 Steven Degutis

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
