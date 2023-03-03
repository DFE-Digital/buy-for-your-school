const firstSelectableTabId = () => {
  const firstTabLink = document.querySelector('.govuk-tabs__list-item a');
  return firstTabLink.getAttribute("href");
}

const currentTabId = () => {
  const currentTabLink = document.querySelector('.govuk-tabs__list-item--selected a');
  return currentTabLink.getAttribute("href");
}

const selectTab = () => {
  const selectTabList = document.querySelector('[data-component="select-tab"] ul');

  if (selectTabList != null) {
    const selectedTabId = currentTabId() || window.location.hash || firstSelectableTabId();
    const selectedTabLink = document.querySelector(`a[href="${selectedTabId}"]`);
    selectedTabLink.click();
  }
};

window.addEventListener("DOMContentLoaded", selectTab);
window.addEventListener("turbo:frame-load", selectTab);
