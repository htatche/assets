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
    lits = gridTitles;

    _this.grid = el.find("#histgrid").jqxGrid({
      width: '900px',
      source: dataAdapter,
      theme: theme,
      columnsresize: true,
      sortable: true,
      pageable: true,
      columns: [
        { text: lits.lit5, datafield: 'datdoc', width: 100 },
        { text: lits.lit2, datafield: 'numdoc', width: 100 },
        { text: lits.lit3, datafield: 'ctcte', width: 100 },
        { text: lits.lit4, datafield: 'ctdesc', width: 150 },
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

  _this.localizeGrid = function() {
    var localizationobj = {};

    localizationobj.pagergotopagestring = "Pàgina:";
    localizationobj.pagershowrowsstring = "Mostrar files:";
    localizationobj.pagerrangestring = " de ";
    localizationobj.pagernextbuttonstring = "Seguent";
    localizationobj.pagerpreviousbuttonstring = "Anterior";
    localizationobj.sortascendingstring = "Ordre ascendent";
    localizationobj.sortdescendingstring = "Ordre descendent";
    localizationobj.sortremovestring = "Eliminar ordre";
    localizationobj.currencysymbol = ' €';
    localizationobj.currencysymbolposition = 'after';
    localizationobj.decimalseparator = ",";
    localizationobj.thousandsseparator = ".";

    el.find('#histgrid').jqxGrid('localizestrings', localizationobj);
  };

  _this.updateGridTitles = function() {
    $.getJSON(
      '/consulta/getGridTitles',
      {opckey: _this.tipusConsulta.val()},
      function(data) {
        var lits = data;

        _this.grid.jqxGrid('setcolumnproperty', 'datdoc',
          'text', lits.lit5);
        _this.grid.jqxGrid('setcolumnproperty', 'numdoc',
          'text', lits.lit2);
        _this.grid.jqxGrid('setcolumnproperty', 'ctcte',
          'text', lits.lit3);
        _this.grid.jqxGrid('setcolumnproperty', 'ctdesc',
          'text', lits.lit4);
      }
    );
  };

  _this.update = function(data) {
    source.localdata = data;
    el.find('#histgrid').jqxGrid('updatebounddata');

    _this.localizeGrid();
    _this.updateGridTitles();
  };
  
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
