(function() {
  // Initialize the sortable library on the lists we need.
  let sortable_elements = [ 'div#documents.gallery.dashboard', 'table.collection-works-table > tbody' ], active_list,
    initialize_sorting, sortable_update, list_to_json, collection_id, page, per_page;

  /*
   * @function
   * Initialize our sorting list.
   * @param {node} element
   *   The element to initialize the sorting on.
   */
  initialize_sorting = function(element) {
    element.sortable({ update: sortable_update, helper: "clone" });
    active_list = element;
  };

  /*
   * @function
   * When user reorders the list, send the new order to the database, via AJAX.
   * @param {event} event
   *   The event.
   * @param {?} ui
   *   The jQuery.ui interface.
   */
  sortable_update = function(event, ui) {
    let url = '/dashboard/collections/update_work_order/' + collection_id() + '/' + page() + '/' + per_page();
    $.ajax({
      type: "POST",
      url: url,
      data: { order: list_to_json }
    })
      .fail(function(XMLHttpRequest, textStatus, errorThrown) {
        window.console.error('Failed to save work order!');
        window.console.error(textStatus);
        window.console.error(errorThrown);
      });
  };

  /*
   * @function
   * Gets the page from the url.
   */
  page = function() {
    let url = new URL(window.location.href);
    return url.searchParams.get("page");
  };

  /*
   * @function
   * Gets the per_page from the url.
   */
  per_page = function() {
    let url = new URL(window.location.href);
    return url.searchParams.get("per_page");
  };

  /*
   * @function
   * Gets the collection id from the url.
   */
  collection_id = function() {
    let url = window.location.pathname;
    return url.substring(url.lastIndexOf('/') + 1);
  };

  /*
   * @function
   * Turns the sortable node object into an array, then that array into a JSON string of document IDs.
   *
   * @return {JSON}
   *   A JSON string of just the ids in the sortable list.
   */
  list_to_json = function() {
    let just_ids = active_list.sortable('toArray')
      .filter(function _remove_detail_ids(id_string) {
        return id_string.includes('document_');
      })
      .map(function _strip_prefix(id_string) {
        return id_string.replace('document_', '');
      });

    return JSON.stringify(just_ids);
  };

  /*
   * DomReady stuff.
   */
  Blacklight.onLoad(function() {
    let tmp, i = 0;

    // Search through our various selectors. If we find one, initialize.
    for(i; i < sortable_elements.length; i++) {
      tmp = $(sortable_elements[i]);
      if(tmp.length > 0) {
        initialize_sorting(tmp);
        break;
      }
    }
  });
})();
