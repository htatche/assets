function Tab (tabIndex) {
  var _this = this;
  _this.tabDiv = $('#tabs-'+tabIndex);

  _this.loadModule = function() {

    objContent = _this.tabDiv.find('.content')
                      .find('div')
                      .first()

    objClass = objContent.attr('class')
                         .split(' ')[0]

    switch (objClass) {
      case 'assistit':
        _this.assistit = new Assistit(_this, objContent, 'new');
        _this.assistit.fire();
        break;
      case 'consulta':
        _this.consulta = new Consulta(_this, objContent);
        _this.consulta.fire();
        break;
      case 'pgcs':
        _this.pgc = new Pgc(_this.tab, objContent);
        _this.pgc.fire();
        break;
    }
  }

  _this.getContent = function() {
    $.get(route, function (data) {
      _this.tabDiv.find('.content').html(data);
    });
  }

  _this.loadMenu = function() {
    menu = _this.tabDiv.find('.jqx-menu').jqxMenu({ width: 'auto'});
  };

  _this.fire = function () {
    menu.bind('itemclick', function(event) {
      route = $(event.args).attr('id');
    });
  };
}
