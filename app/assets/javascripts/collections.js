Blacklight.onLoad(function () {

  /**
   * Handle "delete collection" button click event
   * @param  {Mouseevent} e
   * @return {void}
   */
  function handleDeleteCollection(e) {
    e.preventDefault();
    var $self = $(this),
      $parent = $self.parents('div'),
      totalitems = $self.data('totalitems'),
      // membership set to true indicates admin_set
      membership = $self.data('membership') === true,
      collectionId = $parent.data('id'),
      modalId = '';

    // Permissions denial
    if ($(this).data('hasaccess') !== true) {
      console.log('failed hasaccess');
      $('#collection-to-delete-deny-modal').modal('show');
      return;
    }
    // Admin set with child items
    if (totalitems > 0 && membership) {
      console.log('failed totalitems and membership');
      $('#collection-admin-set-delete-deny-modal').modal('show');
      return;
    }
    modalId = (totalitems > 0 ?
        '#collection-to-delete-modal' :
        '#collection-empty-to-delete-modal'
    );
    addDataAttributesToModal(modalId, ['id', 'post-delete-url'], $parent);
    $(modalId).modal('show');
  }

  $('.delete-collection-button').on('click', handleDeleteCollection);

});