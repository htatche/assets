function Consulta (tab, el) {
  var _this = this;

  var data = '',
      source = {
        datatype: "json",
        datafields: [
          { name: 'datdoc', type: 'date' },
          { name: 'numdoc', type: 'integer' }
        ],
        localdata: data
      };

  var dataAdapter = new $.jqx.dataAdapter(source);

  var mnukey = el.attr('id');

  _this.grid = $("#histgrid").jqxGrid({
      width: 600,
      source: dataAdapter,
      theme: theme,
      columnsresize: true,
      columns: [
        { text: 'Data compra', datafield: 'datdoc', width: 100 },
        { text: 'Nº Factura', datafield: 'numdoc', width: 100 }
      ]
    });

  _this.search = function () {
    $.getJSON('/historials/search',
      {mnukey: _mnukey},
      function(data) {
        _this.update (data);
    })
    .error(function() {
    })
    .complete(function() {
    });

  }

  _this.update = function(data) {
    source.localdata = data;
    $("#histgrid").jqxGrid('updatebounddata');
  }
  
  _this.fire = function() {
    el.jqxExpander({ showArrow: false, toggleMode: 'none' });
    _this.setBindings();
  };

  _this.setBindings = function() {
    el.find('form').submit(function() {
      _this.search();
      
      /* Cancel primary submit action (.preventDefault()) */
      return false;
    });
  };
}
