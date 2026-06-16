// Top level javascript resources
import "core-js/stable"
import "regenerator-runtime/runtime"

import Rails from "@rails/ujs"
Rails.start()

import { initAll } from "govuk-frontend/dist/govuk/govuk-frontend.min.js"
import "govuk_publishing_components/initialise-vars"
import "govuk_publishing_components/modules"
import "govuk_publishing_components/components/layout-super-navigation-header"

const initialiseFrontend = (scope = document) => {
    initAll({ scope });
    window.GOVUK.modules.start(scope);
};

document.addEventListener("DOMContentLoaded", () => initialiseFrontend());
document.addEventListener("turbo:frame-load", (event) => initialiseFrontend(event.target));

import { Turbo } from "@hotwired/turbo-rails"
Turbo.StreamActions.redirect = function () {
    const url = this.getAttribute("url");
    const frameId = this.getAttribute("frame_id");
    const frame = document.querySelector(`turbo-frame#${frameId}`);
    frame.src = url;
};
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
import "./components/sortable-th"
import "./controllers"
