/*
  look for redirect element and redirect to the data-url  
*/

window.addEventListener("load", () => {
  const redirect = document.getElementById("js-redirect");
  if (redirect) {
    window.location.replace(redirect.dataset.redirectUrl);
  }
});
