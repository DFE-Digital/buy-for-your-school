function createProcurementDetails() {
  Rails.ajax({
    url: window.location.pathname,
    type: "PUT"
  })
}

window.addEventListener("load", () => {
  const procurement_details_link = document.getElementById("tab_procurement-details")
  procurement_details_link.addEventListener("click", createProcurementDetails)
})
