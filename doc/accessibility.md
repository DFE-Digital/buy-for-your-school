# Accessibility

To ensure the application is accessible, the following rules should be followed.

[Valid list structures](#valid-list-structures)

## Valid list structures

`ol` and `ul` elements may only contain `li` elements. Unexpected elements may negatively impact the ability of screen readers to correctly announce list items.

Valid:
```html
<ul>
  <li>Item X</li>
  <li>Item Y</li>
  <li>Item Z</li>
</ul>
```

Invalid:
```html
<ul>
  <h2>Items</h2> <!-- Unexpected element -->
  <li>Item X</li>
  <li>Item Y</li>
  <li>Item Z</li>
</ul>
```

More info: https://dequeuniversity.com/rules/axe/4.1/list
