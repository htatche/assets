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
  _this.tipusConsulta = el.find('#tipusConsulta');

  _this.loadGrid = function() {
    $.getJSON(
      '/consulta/getGridTitles',
      {opckey: _this.tipusConsulta.val()},
      function(data) {
        _this.startGrid(data);
      }
    );
  };

  _this.startGrid = function(gridTitles) {
    tit = gridTitles;

    _this.grid = el.find("#histgrid").jqxGrid({
      width: '900px',
      source: dataAdapter,
      theme: theme,
      columnsresize: true,
      columns: [
        { text: tit.lit5, datafield: 'datdoc', width: 100 },
        { text: tit.lit2, datafield: 'numdoc', width: 100 },
        { text: tit.lit3, datafield: 'ctcte', width: 100 },
        { text: tit.lit4, datafield: 'ctdesc', width: 150 },
        { text: 'Data entrada', datafield: 'datsis', width: 100 },
        { text: 'Import', datafield: 'impdoc', width: 100, cellsformat: 'C' },
        { text: 'Comentari', datafield: 'comdoc', width: 250 }
      ]
      });
  };

  _this.search = function () {
    $.getJSON('/historials/search',
      params = el.find('form').serialize(),
      function(data) {
        _this.update (data);
    })
    .error(function() {
    })
    .complete(function() {
    });

  };

  _this.update = function(data) {
    //$('#grid').jqxGrid('setcolumnproperty', 'firstname', 'width', 100);
    source.localdata = data;
    el.find('#histgrid').jqxGrid('updatebounddata');
  }
  
  _this.fire = function() {
    el.jqxExpander({ showArrow: false, toggleMode: 'none' });

    el.find('#dateFrom').datepicker();
    el.find('#dateTo').datepicker();
  
    _this.setBindings();

    _this.loadGrid();
  };

  _this.setBindings = function() {
    el.find('form').submit(function() {
      _this.search();
      
      /* Cancel primary submit action (.preventDefault()) */
      return false;
    });
  };
}
