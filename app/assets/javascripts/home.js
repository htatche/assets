$(document).ready(function() {

  tabs = [];

  loadPage = function (route, tabIndex, name) {

    $.get(route, function (data) {
    
        html = '<div id="tabs-' + tabIndex + '"><div class="tab-container">' + data + '</div></div>';
        $('#appTabs').jqxTabs('addLast', name, html);

        tabs.push({tab: new Tab(tabIndex)});

        arrayIndex = tabs.length - 1;
        tabs[arrayIndex].tab.fire();
    });
  }

  $('div.menuOptions').find('div.option').dblclick(function() {
    var route = $(this).attr('id');
    var pageIndex = $('#appTabs').jqxTabs('length') + 1;
    var title = $(this).attr('name');

    var html = loadPage(route, pageIndex, title);
  });

  $('div.menuOptions').find('div.option').hover(
    function() {
      $(this).addClass('hover');
    },
    function() {
      $(this).removeClass('hover');
    }
  );

  var route = 'home/home';
  var pageIndex = $('#appTabs').jqxTabs('length') + 1;
  var title = 'Inici';

  var html = loadPage(route, pageIndex, title);
});
