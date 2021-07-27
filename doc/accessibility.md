# Accessibility

To ensure the application is accessible, the following rules should be followed.

1. [Valid list structures](#valid-list-structures)
1. [Button role](#button-role)

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

## Button role

Throughout the application we use links with `.govuk-button` styling to act as buttons. In order for screen readers to recognise these as buttons and not links, we need to use the `role: "button"` attribute on our links.

Valid:
```erb
<%= link_to "Button", route_path, class: "govuk-button", role: "button" %>
```
Invalid:
```erb
<%= link_to "Button", route_path, class: "govuk-button" %> <!-- note the missing role -->
```

More info: https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Roles/button_role
