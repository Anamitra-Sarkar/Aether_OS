# AetherOS Design Tokens

This document defines the design tokens used throughout AetherOS to ensure visual consistency across all applications and UI components.

## Color Palette

### Primary Colors

| Token | Light Mode | Dark Mode | Usage |
|-------|------------|-----------|-------|
| `accent-primary` | `#6C8CFF` | `#6C8CFF` | Primary actions, links, focus states |
| `accent-secondary` | `#7AE7C7` | `#7AE7C7` | Secondary highlights, success states |

### Background Colors

| Token | Light Mode | Dark Mode | Usage |
|-------|------------|-----------|-------|
| `bg-base` | `#F6F8FA` | `#0F1720` | Main window backgrounds |
| `bg-surface` | `#FFFFFF` | `#101317` | Cards, panels, dialogs |
| `bg-elevated` | `#FFFFFF` | `#1A1F26` | Elevated surfaces, popovers |

### Text Colors

| Token | Light Mode | Dark Mode | Usage |
|-------|------------|-----------|-------|
| `text-primary` | `#1F2937` | `#E5E7EB` | Primary text, headings |
| `text-secondary` | `#6B7280` | `#9CA3AF` | Secondary text, labels |
| `text-muted` | `#9CA3AF` | `#6B7280` | Disabled text, hints |

### Semantic Colors

| Token | Color | Usage |
|-------|-------|-------|
| `success` | `#22C55E` | Success messages, confirmations |
| `warning` | `#F59E0B` | Warnings, cautions |
| `error` | `#EF4444` | Errors, destructive actions |
| `info` | `#3B82F6` | Information, tips |

## Typography

### Font Family

```css
font-family: 'Inter', 'Noto Sans', -apple-system, BlinkMacSystemFont, sans-serif;
```

### Font Sizes

| Token | Size | Line Height | Usage |
|-------|------|-------------|-------|
| `text-xs` | 11px | 1.4 | Captions, labels |
| `text-sm` | 13px | 1.5 | Secondary text |
| `text-base` | 15px | 1.5 | Body text |
| `text-lg` | 17px | 1.4 | Subheadings |
| `text-xl` | 20px | 1.3 | Headings |
| `text-2xl` | 24px | 1.2 | Page titles |
| `text-3xl` | 32px | 1.1 | Large titles |

### Font Weights

| Token | Weight | Usage |
|-------|--------|-------|
| `font-normal` | 400 | Body text |
| `font-medium` | 500 | Emphasis |
| `font-semibold` | 600 | Headings |
| `font-bold` | 700 | Strong emphasis |

## Spacing

### Base Unit

The base spacing unit is **4px**. All spacing values should be multiples of this base unit.

| Token | Value | Usage |
|-------|-------|-------|
| `space-1` | 4px | Tight spacing |
| `space-2` | 8px | Compact elements |
| `space-3` | 12px | Default padding |
| `space-4` | 16px | Standard gaps |
| `space-5` | 20px | Comfortable spacing |
| `space-6` | 24px | Section padding |
| `space-8` | 32px | Large gaps |
| `space-10` | 40px | Section margins |
| `space-12` | 48px | Page margins |

## Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| `radius-sm` | 6px | Small elements (badges, tags) |
| `radius-md` | 10px | Medium elements (buttons, inputs) |
| `radius-lg` | 12px | Large elements (cards, panels) |
| `radius-xl` | 16px | Extra large (modals, sheets) |
| `radius-full` | 9999px | Pills, avatars |

## Shadows

### Elevation Levels

```css
/* Level 1 - Subtle */
shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.05);

/* Level 2 - Cards */
shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1),
           0 2px 4px -1px rgba(0, 0, 0, 0.06);

/* Level 3 - Dropdowns, Popovers */
shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1),
           0 4px 6px -2px rgba(0, 0, 0, 0.05);

/* Level 4 - Modals */
shadow-xl: 0 20px 25px -5px rgba(0, 0, 0, 0.1),
           0 10px 10px -5px rgba(0, 0, 0, 0.04);
```

## Animation

### Duration

| Token | Duration | Usage |
|-------|----------|-------|
| `duration-fast` | 100ms | Micro-interactions |
| `duration-base` | 150ms | Standard transitions |
| `duration-moderate` | 220ms | Modal animations |
| `duration-slow` | 300ms | Complex animations |

### Easing

```css
/* Default easing - Smooth and polished */
ease-default: cubic-bezier(0.22, 1, 0.36, 1);

/* Entrance easing - Quick entry */
ease-in: cubic-bezier(0.4, 0, 1, 1);

/* Exit easing - Smooth exit */
ease-out: cubic-bezier(0, 0, 0.2, 1);

/* Bounce easing - Playful */
ease-bounce: cubic-bezier(0.34, 1.56, 0.64, 1);
```

### Reduced Motion

When reduced motion is preferred, all animations should:
- Have duration of 0ms
- Remove transform-based animations
- Keep opacity transitions (at reduced duration)

```css
@media (prefers-reduced-motion: reduce) {
    *,
    *::before,
    *::after {
        animation-duration: 0.01ms !important;
        animation-iteration-count: 1 !important;
        transition-duration: 0.01ms !important;
    }
}
```

## Z-Index Scale

| Token | Value | Usage |
|-------|-------|-------|
| `z-base` | 0 | Default layer |
| `z-dropdown` | 10 | Dropdowns |
| `z-sticky` | 20 | Sticky headers |
| `z-overlay` | 30 | Overlays |
| `z-modal` | 40 | Modals |
| `z-popover` | 50 | Popovers, tooltips |
| `z-toast` | 60 | Toast notifications |
| `z-tooltip` | 70 | Tooltips |

## Breakpoints

| Token | Value | Usage |
|-------|-------|-------|
| `screen-sm` | 640px | Small screens |
| `screen-md` | 768px | Tablets |
| `screen-lg` | 1024px | Laptops |
| `screen-xl` | 1280px | Desktops |
| `screen-2xl` | 1536px | Large desktops |

## Icon Sizes

| Token | Size | Usage |
|-------|------|-------|
| `icon-xs` | 12px | Inline icons |
| `icon-sm` | 16px | Small buttons |
| `icon-md` | 20px | Default icons |
| `icon-lg` | 24px | Large buttons |
| `icon-xl` | 32px | Feature icons |

## Usage in Code

### KDE/Qt (QML)

```qml
// Colors
readonly property color accentPrimary: "#6C8CFF"
readonly property color bgDark: "#0F1720"

// Animation
Behavior on opacity {
    NumberAnimation {
        duration: 150
        easing.type: Easing.OutCubic
    }
}
```

### GTK/CSS

```css
@define-color accent_color #6C8CFF;
@define-color bg_color #0F1720;

button {
    border-radius: 10px;
    transition: all 150ms cubic-bezier(0.22, 1, 0.36, 1);
}
```

### Shell Scripts

```bash
# AetherOS Brand Colors
AETHER_BLUE="#6C8CFF"
AETHER_MINT="#7AE7C7"
AETHER_BG_DARK="#0F1720"
AETHER_BG_LIGHT="#F6F8FA"
```

## Accessibility

- Ensure contrast ratio of at least 4.5:1 for normal text
- Ensure contrast ratio of at least 3:1 for large text
- Provide focus indicators with at least 3px outline
- Support high contrast mode
- Support reduced motion preferences
