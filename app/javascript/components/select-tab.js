window.addEventListener("DOMContentLoaded", () => {
  const selectTabList = document.querySelector('[data-component="select-tab"] ul');

  if (selectTabList != null) {
    const selectedTabId = selectTabList.getAttribute("selected");
    const selectedTab = document.getElementById(selectedTabId);
    const selectedTabLink = selectedTab.querySelector("a");
    selectedTab.classList.add("govuk-tabs__list-item--selected");
    selectedTabLink.setAttribute("aria-selected", "true");
    selectedTabLink.setAttribute("tabindex", "0");
  }
});
