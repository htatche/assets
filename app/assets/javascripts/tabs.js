function Tab (tabIndex) {
  var _this = this;

  _this.htmlDiv = $('#tabs-'+tabIndex);

  _this.loadModule = function(moduleName) {

    switch (moduleName) {
      case 'assistit':
        _this.assistit = new Assistit(_this, 'new');
        _this.assistit.fire();
        break;
      case 'consulta':
        _this.consulta = new Consulta(_this);
        _this.consulta.fire();
        break;
      case 'pgcs':
        _this.pgc = new Pgc(_this.tab, objContent);
        _this.pgc.fire();
        break;
    }
  }

  _this.getContent = function(route) {
    $.get(route, function (data) {
      content = _this.htmlDiv.find('.content');
      content.html(data);

      var moduleName = content.find('div').first()
                              .attr('class').split(' ')[0];

      _this.loadModule(moduleName);
    });
  }

  _this.loadMenu = function() {
    menu = _this.htmlDiv.find('.jqx-menu').jqxMenu({ width: 'auto'});

    menu.bind('itemclick', function(event) {
      route = $(event.args).attr('id');
      _this.getContent(route);
    });
  };

  _this.fire = function () {
    _this.loadMenu();
  };
}
