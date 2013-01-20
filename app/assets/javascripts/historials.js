function Consulta (tab, el) {
  var _this = this;

  var data = '',
      source = {
        datatype: "json",
        datafields: [
          { name: 'datdoc', type: 'string' },
          { name: 'numdoc', type: 'integer' },
          { name: 'ctcte', type: 'string' },
          { name: 'ctdesc', type: 'string' },
          { name: 'datsis', type: 'string' },
          { name: 'impdoc', type: 'float' },
          { name: 'comdoc', type: 'string' }
        ],
        localdata: data
      };

  var dataAdapter = new $.jqx.dataAdapter(source);

  _this.mnukey = el.attr('id');

  _this.grid = $("#histgrid").jqxGrid({
      width: '800px',
      source: dataAdapter,
      theme: theme,
      columnsresize: true,
      columns: [
        { text: 'Data compra', datafield: 'datdoc', width: 100 },
        { text: 'Nº Factura', datafield: 'numdoc', width: 100 },
        { text: 'Codi proveidor', datafield: 'ctcte', width: 100 },
        { text: 'Proveidor', datafield: 'ctdesc', width: 100 },
        { text: 'Data entrada', datafield: 'datsis', width: 100 },
        { text: 'Import', datafield: 'impdoc', width: 50, cellsformat: 'C' },
        { text: 'Comentari', datafield: 'comdoc', width: 200 }
      ]
    });

  _this.search = function () {
    $.getJSON('/historials/search',
      {mnukey: _this.mnukey},
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

    el.find('#dateFrom').datepicker();
    el.find('#dateTo').datepicker();

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
