(function tuftsSortableSubcollections() {
  let sortable_element = '#sub-collections-wrapper .collections-list', active_list,
    initialize_sorting, sortable_update, list_to_json, collection_id;

 /*
  * @function
  * Initialize our sorting list.
  */
  initialize_sorting = function() {
    let sub_list = $(sortable_element);

    if(sub_list.length > 0) {
      sub_list.sortable({ update: sortable_update,  placeholder: 'subcollection-placeholder'});
      active_list = sub_list;
    }
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
    let url = '/dashboard/collections/update_subcollection_order/' + collection_id();

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
    let just_ids = active_list.sortable('toArray', {attribute: 'data-id'});
    return JSON.stringify(just_ids);
  };

 /*
  * DomReady stuff.
  */
  Blacklight.onLoad(function() {
    initialize_sorting();
  });
})();