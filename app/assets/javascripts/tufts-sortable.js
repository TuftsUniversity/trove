Blacklight.onLoad(function() {
  // Initialize the sortable library on the lists we need.
  var sortable_elements = ['div#documents', '.hyc-bl-results table tbody'],
    i = 0;
  for(i; i < sortable_elements.length; i++) {
    el = $(sortable_elements[i]);
    if(el.length > 0) {
      el.sortable();
    }
  }
});