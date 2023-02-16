// Top level javascript resources

import "core-js/stable"
import "regenerator-runtime/runtime"

import Rails from "@rails/ujs"
Rails.start()

import { initAll } from "govuk-frontend/govuk/all"
(() => { document.addEventListener('DOMContentLoaded', initAll); })();

import { Turbo } from "@hotwired/turbo-rails"
Turbo.session.drive = false

// Application javascript resources

import "./components/autocomplete"
import "./components/close-tab-link"
import "./components/display-attachments"
import "./components/hide"
import "./components/tinymce"
import "./components/toggle-panel-visibility"
import "./components/toggle-truncate"
import "./components/view-hidden-responses"
import "./components/select-tab"
import "./components/add-recipients"
import "./components/display-cc-bcc"
import "./controllers"
