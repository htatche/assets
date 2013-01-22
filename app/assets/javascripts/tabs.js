function Tab (tabIndex) {
  _this = this;
  _this.tab = $('#tabs-'+tabIndex);
  _this.index = tabIndex;

  _this.fire = function() {
    menu = _this.tab.find('.jqx-menu').jqxMenu({ width: 'auto'});
    menu.bind('itemclick', function(event) {
      route = $(event.args).attr('id');

      $.get(route, function (data) {
        _this.tab.find('.content').html(data);

        objContent = _this.tab.find('.content')
                          .find('div')
                          .first()

        objClass = objContent.attr('class')
                              .split(' ')[0]

        switch (objClass) {
          case 'assistit':
            obj = new Assistit(_this.tab, objContent, 'new');
            break;
          case 'consulta':
            obj = new Consulta(_this.tab, objContent);
            break;
          case 'pgcs':
            obj = new Pgc(_this.tab, objContent);
            break;
        }

        obj.fire();
      });
    });
  };
}
