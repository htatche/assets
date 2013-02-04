function Tab (tabIndex) {
  var _this = this,
      content,
      menu;

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
        _this.pgc = new Pgc(_this);
        _this.pgc.fire();
        break;
      case 'assentament':
        _this.assentament = new AssentamentForm(_this);
        _this.assentament.fire();
        break;
    }
  }

  _this.getContent = function(route, moduleName) {

    $.get(route, function (data) {
      content    = _this.htmlDiv.find('.content').html(data),
      moduleName = moduleName || content.find('div').first()
                                 .attr('class').split(' ')[0]
      _this.loadModule(moduleName);
    });
  }

  _this.loadMenu = function() {
    menu = _this.htmlDiv.find('.jqx-menu');

    menu.jqxMenu({
      width: 'auto',
      animationShowDuration: 0,
      animationHideDuration: 0
    });

    menu.bind('itemclick', function(event) {
      var route = $(event.args).attr('id');

      _this.getContent(route, null);
    });
  };

  _this.fire = function () {
    _this.loadMenu();
  };
}
