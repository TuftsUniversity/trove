(function tuftsDragAndDropScope() {

  // Manages the drag and drop functionality in the search results.
  let tuftsDragAndDrop = function tuftsDragAndDrop() {
    let valid_dzs, dropzone_class = 'tufts-dropzone', dragging_class = 'dragging', hover_class = "drag-hover",
      init, highlight_dropzones, unhighlight_dropzones, add_hover, remove_hover,
      allow_drop, save_doc_id, strip_doc_prefix,
      add_image_to_collection;

    init = function() {
      valid_dzs = document.querySelectorAll('#collections-sidebar .tufts-dropzone');
      if(valid_dzs.length === 0) {
        return;
      }
      document.addEventListener('dragstart', highlight_dropzones);
      document.addEventListener('dragstart', save_doc_id);
      document.addEventListener('dragend', unhighlight_dropzones);
      document.addEventListener('dragover', allow_drop);
      document.addEventListener('drop', add_image_to_collection);
      document.addEventListener('drop', remove_hover);
      document.addEventListener('dragenter', add_hover);
      document.addEventListener('dragleave', remove_hover);
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

    // Fires the ajax event that saves the image to the collection
    add_image_to_collection = function(ev) {
      let el = ev.target;

      if(el.classList.contains(dropzone_class)) {
        ev.preventDefault();
        let collection_id = el.id,
          image_id = ev.dataTransfer.getData('text/plain');
        console.log("Saving " + image_id + " to " + collection_id);
        ev.stopPropagation();
      }
    };

    // Saves the doc id to the event
    save_doc_id = function(ev) {
      ev.dataTransfer.dropEffect = "copy";
      ev.dataTransfer.setData('text/plain', strip_doc_prefix(ev.target.id));
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