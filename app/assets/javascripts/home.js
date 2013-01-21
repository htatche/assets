$(document).ready(function() {

  tabs = [];

  var loadPage = function (route, tabIndex, name) {

    $.get(route, function (data) {
    
        html = '<div id="tabs-' + tabIndex + '"><div class="tab-container">' + data + '</div></div>';
        $('#appTabs').jqxTabs('addLast', name, html);

        /* Load JS depending on option */
        //if (/^assistits\//.test(route)) {
        //}
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
});
