$(document).ready(function() {

  tabs = [];

  loadTab = function (route, name) {

    var index = $('#appTabs').jqxTabs('length') + 1,
        ntabs = tabs.length - 1;

    $.get(route, function (data) {
    
        html = '<div id="tabs-' + index + '">'
        html = html + '<div class="tab-container">' + data + '</div>'
        html = html + '</div>';

        $('#appTabs').jqxTabs('addLast', name, html);

        var tab = new Tab(index);

        tabs.push(tab);
        tab.fire();
    });
  }

  $('div.menuOptions').find('div.option').dblclick(function() {
    var route = $(this).attr('id');
    var title = $(this).attr('name');

    loadTab(route, title);
  });

  $('div.menuOptions').find('div.option').hover(
    function() {
      $(this).addClass('hover');
    },
    function() {
      $(this).removeClass('hover');
    }
  );

  // Prevent text and menu icons from being selected
  $('div.menuOptions').live('selectstart dragstart', function(evt) {
    evt.preventDefault();
    return false;
  });

});
