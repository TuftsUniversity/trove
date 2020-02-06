function filter_options(keyword) {
  let filter = keyword.toUpperCase(),
    lis = document.getElementsByClassName('col-name');

  for (let i = 0; i < lis.length; i++) {
      let name = $(lis[i]).find('label').text();
      if (name.toUpperCase().indexOf(filter) >= 0)
          lis[i].style.display = 'list-item';
      else
          lis[i].style.display = 'none';
  }
}
