# Form Objects

Explains the pattern and motivation of using form objects in Rails applications.

## Motivation

Whilst building forms in Rails is a simple task until you want more complex setups around validations, setting attributes depending on other values or multi - step (wizard style).

## Multi Step

`app/forms/support_form`

This form could become more complex and consists of multiple steps / splitting the form (note - this could be achieved with frontend JS).

The basic principal is to include `ActiveModel::Model` which allows adding validations (keeping models thin) - then creating subclasses for each step of the form including any validations / custom logic for the given `step`.
