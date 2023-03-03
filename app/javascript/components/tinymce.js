// use data-tinymce-profile="basic" in your markup to select basic profile

const basicProfile = {
  plugins: [
    "advlist",
    "autolink",
    "link",
    "lists",
    "anchor",
    "searchreplace",
    "visualblocks",
    "visualchars",
    "insertdatetime",
    "table",
    "help",
    "fullscreen",
    "emoticons",
    "preview"
  ],
  toolbar: [
    // "undo redo",
    // "styles",
    "bold italic underline",
    "link table",
    "alignleft aligncenter alignright alignjustify",
    "bullist numlist",
    "outdent indent",
    "forecolor backcolor",
    "fullscreen preview"
  ].join(" | ")
}

const profiles = {
  basic: basicProfile
}

// init the component

const initializeTinymce = editorElement => {
  const {
    tinymceSelector: selector,
    tinymcePlugins,
    tinymceToolbar,
    tinymceProfile
  } = editorElement.dataset;

  const customProfile = {
    plugins: tinymcePlugins ? tinymcePlugins.split(",") : null,
    toolbar: tinymceToolbar
  };

  const profile = profiles[tinymceProfile] || customProfile;

  tinymce.init({
    ...profile,
    selector,
    menubar: false,
    statusbar: false,
    contextmenu: false,
    browser_spellcheck: true
  });
}

// on page load

const loadTinymce = () => {
  const elements = document.querySelectorAll('[data-component="tinymce"]');
  elements.forEach(initializeTinymce);
};

window.addEventListener("DOMContentLoaded", loadTinymce);
window.addEventListener("turbo:frame-load", loadTinymce);
