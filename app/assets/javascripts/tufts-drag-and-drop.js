(function tuftsDragAndDropScope() {

  // Manages the drag and drop functionality in the search results.
  let tuftsDragAndDrop = function tuftsDragAndDrop() {
    let valid_dzs, dropzone_class = 'tufts-dropzone', dragging_class = 'dragging', hover_class = "drag-hover",
      init, get_username, strip_doc_prefix, store_doc_id,
      highlight_dropzones, unhighlight_dropzones, add_hover, remove_hover, allow_drop,
      add_image_to_collection, send_update;

    init = function() {
      valid_dzs = document.querySelectorAll('#collections-sidebar .tufts-dropzone');
      if(valid_dzs.length === 0) {
        return;
      }
      document.addEventListener('dragstart', highlight_dropzones);
      document.addEventListener('dragstart', store_doc_id);
      document.addEventListener('dragend', unhighlight_dropzones);
      document.addEventListener('dragenter', add_hover);
      document.addEventListener('dragleave', remove_hover);
      document.addEventListener('dragover', allow_drop);
      document.addEventListener('drop', add_image_to_collection);
      document.addEventListener('drop', remove_hover);
    };

    // Fires the ajax event that saves the image to the collection
    add_image_to_collection = function(ev) {
      let el = ev.target;

      if(el.classList.contains(dropzone_class)) {
        ev.preventDefault();

        let collection_id = el.id,
          image_id = ev.dataTransfer.getData('text/plain');

        console.log("Saving " + image_id + " to " + collection_id);

        send_update(collection_id, image_id);
      }
    };

    /* Sends the ajax request to add the image to the collection
     * @param {str} collection
     *   The collection id to save the image in
     * @param {str} image
     *   The image id */
    send_update = function(collection, image) {
      $.ajax({
        url: '/dashboard/collections/' + collection,
        //collection['members'] is necessary for CollectionMembersController#validate
        data: { batch_document_ids: [image], origin: 'dragndrop', collection: { members: 'add' } },
        method: 'POST'
      })
        .fail(function(XMLHttpRequest, textStatus, errorThrown) {
          window.console.error('Failed to save work order!');
          window.console.error(textStatus);
          window.console.error(errorThrown);
        });
    };

    // Changes the sidebar collections to display like valid dropzones.
    highlight_dropzones = function() {
      valid_dzs.forEach(function(item) {
        item.classList.add(dragging_class);
      });
    };

    // Reverts the sidebar collection display
    unhighlight_dropzones = function() {
      valid_dzs.forEach(function(item) {
        item.classList.remove(dragging_class);
      });
    };

    // Adds a hover class to the hovered element, if it's a dropzone
    add_hover = function(ev) {
      let el = ev.target;
      if(el.classList.contains(dropzone_class)) {
        el.classList.add(hover_class);
      }
    };

    // Removes the hover class from an element
    remove_hover = function(ev) {
      let el = ev.target;
      if(el.classList.contains(hover_class)) {
        el.classList.remove(hover_class);
      }
    };

    // Allows dropping something into elements with the dropzone class
    allow_drop = function(ev) {
      let el = ev.target;
      if(el.classList.contains(dropzone_class)) {
        ev.preventDefault();
      }
    };

    // Saves the doc id to the event
    store_doc_id = function(ev) {
      ev.dataTransfer.dropEffect = "copy";
      ev.dataTransfer.setData('text/plain', strip_doc_prefix(ev.target.id));
    };

    // Nabs the username from the body element
    get_username = function() {
      return document.body.dataset.username
    };

    /* Removes the document_ from the item ids
     * @param {str} id
     *   The text from the id attribute of the item */
    strip_doc_prefix = function(id) {
      return id.replace('document_', '');
    };
    return { init: init };
  };

  Blacklight.onLoad(function() {
    tuftsDragAndDrop().init();
  });
})();