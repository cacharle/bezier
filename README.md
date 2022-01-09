# Bezier

![screenshot](./screenshot.png)

Visualization of a [Bézier curve][1] in Scheme.

Inpired by a [Coding train video][2].

## Usage

Install [Chicken Scheme][3] and the [SDL2 bindings][4].

```
$ chicken-install sdl2  # takes 5min
```

Compile and run:

```
$ chicken-csc -O5 bezier.scm
$ ./bezier
```

## Keybindings

* `Escape` or `q` to quit
* Click on a control point (little square) to drag it around
* `Up`/`Down` to add/remove control point

[1]: https://en.wikipedia.org/wiki/B%C3%A9zier_curve
[2]: https://www.youtube.com/watch?v=enNfb6p3j_g
[3]: http://code.call-cc.org/
[4]: http://wiki.call-cc.org/eggref/5/sdl2
