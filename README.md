# Vivaldi Arc-Style Autohide CSS

Arc Browser-like autohide for Vivaldi's vertical tab bar (left) and web panel (right). Tab bar and panel never show at the same time. When a web panel tab is open it sticks and pushes the page; when only the icon strip is visible it autohides as an overlay.

## Files

- `arc-style-autohide-tabs-sticky-panel.css` — the active file Vivaldi loads
- `arc-style-autohide-tabs.css.bak` — backup of the last known-good state before sticky panel was added

Vivaldi is pointed at this **folder**, not a specific file. It loads every `.css` file in the folder, so never have more than one `.css` file here.

## Tuning (edit these at the top of the CSS)

```css
--tabbar-peek-width: 3px;    /* how much of the tab bar peeks out when hidden */
--panel-top-offset: 53px;    /* match your toolbar/address bar height */
--panel-bottom-offset: 34px; /* match your status bar height */
```

---

## How it works & why

### Tab bar

Uses `position: absolute` + `transform: translateX()`. Taking it out of flow means the webpage fills the full width; the transform slides it off-screen leaving a `--tabbar-peek-width` strip. `transform` is GPU-composited — no layout reflow, perfectly smooth.

This works because `.tabbar-wrapper` sits in a part of the DOM where its containing block doesn't have `overflow: hidden`, so the peek strip stays hoverable even when mostly off-screen.

### Web panel — why it's more complicated

`#panels-container` lives inside an inner flex container (likely `.inner`) that **does** have `overflow: hidden`. That means:

- `position: absolute` + `transform`: the peek strip slides outside the parent's clipping bounds → pointer events are clipped → hover never fires. Every attempt at this approach silently failed.
- `transform` while staying in-flow (no `position: absolute`): smooth animation, but the element still occupies its full layout width → the parent's background bleeds through as a permanent gray bar.
- `max-width` + `overflow: hidden` while in-flow: no gray bar, hover works, but `max-width` causes layout reflow on every animation frame → visibly choppy. Also the easing feels wrong unless `max-width` is set to a value close to the panel's actual width (otherwise the visible portion of the animation is crammed into the first few percent of the timeline).

**The solution: `position: fixed`.**

Fixed elements are positioned relative to the viewport and are **never clipped by ancestor `overflow: hidden`**. The peek strip stays inside the viewport bounds and receives pointer events normally. `transform` can then be used for the slide, giving smooth GPU-composited animation while overlaying the page. `top` and `bottom` offsets are needed to keep it within the content area (clear of toolbar and status bar).

### Sticky panel when open

Vivaldi adds/removes a class on `#panels-container` to reflect panel state:

| State | Class on `#panels-container` |
|---|---|
| Only icon strip visible | `.icons` |
| A panel tab is open | *(no `.icons` class)* |

So `#panels-container:not(.icons)` reliably detects "a panel is open." In that state the `position: fixed` autohide rules are overridden: the panel reverts to `position: static` (back in flex flow), pushes the page, and stays permanently visible.

### Mutual exclusion

CSS `:has()` is used to ensure tab bar and panel never show simultaneously:
- Hovering the panel → tab bar is forced hidden
- Hovering the tab bar → panel is forced hidden

Since both use hover and you can only hover one side at a time, this is mostly natural — but the explicit rules prevent edge cases during fast mouse movement.

---

## Vivaldi DOM quick reference

```
#browser                        root browser element
  .tabs-left / .tabs-right      class indicating tab bar side
  .tabbar-wrapper               vertical tab bar container
  .mainbar                      top toolbar area (address bar etc.)
  .webpage                      the actual web content area
  #panels-container             web panel container (right side)
    .icons                      class present when ONLY icon strip is showing
    #switch                     the icon strip itself
```

**Other useful selectors:**
- `#switch button.active` — the currently selected panel icon button
- `#browser.tabs-left` / `#browser.tabs-right` — tab bar position
