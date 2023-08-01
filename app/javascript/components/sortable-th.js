function getSortableThs(scope) {
  return Array.from(scope.querySelectorAll('[data-component="sortable-th"]'));
}

function getNextSort(currentSort, sortConfig) {
  switch(sortConfig) {
    case "asc_desc":
      return currentSort === "none" || currentSort === "descending" ? "ascending" : "descending";
    case "desc_asc":
      return currentSort === "none" || currentSort === "ascending" ? "descending" : "ascending";
    default:
      return "ascending";
  }
}

const sortableTh = (config) => {
  config = config || {};
  const scope = config.scope || document;
  const sortableThs = getSortableThs(scope);
  const sortableThInputs = new Map(sortableThs.map(obj => [obj.id, Array.from(obj.getElementsByTagName("input"))]));
  sortableThs.forEach(th => {
    const button = th.getElementsByTagName("button")[0];
    const sortOrderInput = th.querySelector("input[name$='[sort_order]']");
    const currentSort = th.getAttribute("aria-sort");
    const sortConfig = th.getAttribute("data-sort-config")
    button.addEventListener("click", () => {
      sortOrderInput.value = getNextSort(currentSort, sortConfig);
      // disable other sort inputs so only this value is submitted
      otherInputs = new Map([...sortableThInputs].filter(([key]) => key !== th.id));
      otherInputs.forEach(inputArray => inputArray.forEach(i => i.disabled = true));
    });
  });
};

window.addEventListener("DOMContentLoaded", sortableTh);
window.addEventListener("turbo:frame-load", (event) => sortableTh({ scope: event.target }));
