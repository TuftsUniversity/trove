function filter_options(keyword) {
var filter = keyword.toUpperCase();
var lis = document.getElementsByClassName('col-name');
for (var i = 0; i < lis.length; i++) {
    var name = $(lis[i]).find('label').text();
    if (name.toUpperCase().indexOf(filter) >= 0)
        lis[i].style.display = 'list-item';
    else
        lis[i].style.display = 'none';
}
}
