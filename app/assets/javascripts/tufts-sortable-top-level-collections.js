(function tuftsSortableTopLevelCollections() {
  let target_xpaths = [
    { button: '.reorder-course', list: '.top-level-course-collections' },
    { button: '.reorder-personal', list: '.top-level-personal-collections' }
  ];

  // Sets up a single pair of a button and sortable list.
  let sortableTopLevelCollection = function(xpaths) {
    let button, list, currently_sorting = false, original_list, type = "personal", user_id,
      init, list_to_json, collapse_all,
      button_to_sorting_mode, button_to_normal_mode, button_text, prev_button, icon_classes = 'glyphicon glyphicon-sort',
      enable_sorting, disable_sorting, toggle_sorting,
      sortable_update;

    init = function(xpaths) {
      button = $(xpaths['button']);
      list = $(xpaths['list']);

      if(button.length === 0 || list.length === 0) {
        return;
      }

      // This may be a slightly verbose way of doing this, but we shouldn't default to altering course collections.
      if(button.data('user') === 'courses') {
        type = 'course';
      } else {
        user_id = button.data('user');
      }
      button_text = button.find('span');
      prev_button = button.prev('.btn');

      button.on('click', toggle_sorting);
    };

    // Initializes the sorting library on 'list'. Saves the original order for evaluation.
    enable_sorting = function() {
      list.sortable({
        placeholder: 'collection-placeholder',
        create: function() { original_list = list_to_json(); }
      });
    };

    // Removes sorting library functionality from 'list'. Runs sortable_update ajax call if lists have changed.
    disable_sorting = function() {
      let new_list = list_to_json();
      if(new_list !== original_list) {
        sortable_update(new_list);
      }

      original_list = '';
      list.sortable('destroy');
    };

    // Handler for 'button', which toggles the sorting of the list.
    toggle_sorting = function(e) {
      e.preventDefault();

      if(currently_sorting) {
        disable_sorting();
        button_to_normal_mode();
        currently_sorting = false;
      } else {
        currently_sorting = true;
        collapse_all();
        enable_sorting();
        button_to_sorting_mode();
      }
    };

    // Ajax call that actually sends the new list to be saved.
    sortable_update = function(list) {
      let url = type === 'course' ?
        '/update_top_level_course_collection' :
        '/update_top_level_personal_collection/' + user_id;

      $.ajax({
        type: "POST",
        url: url,
        data: { order: list }
      })
        .fail(function(XMLHttpRequest, textStatus, errorThrown) {
          window.console.error('Failed to save work order!');
          window.console.error(textStatus);
          window.console.error(errorThrown);
        });
    };

    // Returns JSON of data-id attributes in 'list'.
    list_to_json = function() {
      let ids = [];

      if(!currently_sorting) {
        window.console.warn("Can't get order from a list that's not sorting.");
        return;
      }

      ids = list.sortable('toArray', { attribute: 'data-id' });
      return JSON.stringify(ids);
    };

    // Collapses all open lists.
    collapse_all = function() {
      list.find('.collapse.in').collapse('hide');
    };

    // Changes the button to say 'Save' and removes + button for space.
    button_to_sorting_mode = function() {
      prev_button.addClass('hidden');
      button_text.removeClass(icon_classes);
      button_text.text('Save');
    };

    // Reverts buttons after sorting.
    button_to_normal_mode = function() {
      prev_button.removeClass('hidden');
      button_text.text('');
      button_text.addClass(icon_classes);
    };

    return { init: init };
  };

  // DomReady stuff. Initialize the prior cod onto all 'target_xpaths'.
  Blacklight.onLoad(function() {
    target_xpaths.forEach(function initSortableTopLevelColls(hash) {
      sortableTopLevelCollection().init(hash);
    });
  });
})();