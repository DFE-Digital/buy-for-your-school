function getSortableThs(scope) {
  return Array.from(scope.querySelectorAll('[data-component="sortable-th"]'));
}

function getNextSort(currentSort, sortOrder) {
  switch(sortOrder) {
    case "asc_desc":
      return currentSort === "none" || currentSort === "descending" ? "ascending" : "descending";
    case "desc_asc":
      return currentSort === "none" || currentSort === "ascending" ? "descending" : "ascending";
    default:
      return "ascending";
  }
}

const sortableTh = (config) => {
  config = config || {}
  const scope = config.scope || document
  const sortableThs = getSortableThs(scope);
  const sortableThInputs = sortableThs.map((sortableTh) => sortableTh.getElementsByTagName("input")[0]);
  sortableThs.forEach(th => {
    const button = th.getElementsByTagName("button")[0];
    const input = th.getElementsByTagName("input")[0];
    const currentSort = th.getAttribute("aria-sort");
    const sortOrder = th.getAttribute("data-sort-order")
    button.addEventListener("click", () => {
      input.value = getNextSort(currentSort, sortOrder);
      // disable other sort inputs so only this value is submitted
      sortableThInputs.filter(i => i !== input).forEach(i => i.disabled = true);
    });
  });
};

window.addEventListener("DOMContentLoaded", sortableTh);
window.addEventListener("turbo:frame-load", (event) => sortableTh({ scope: event.target }));
