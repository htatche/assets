function AssentamentForm (tab) {
  var _this        = this;
      moduleName   = 'assentament',
      htmlDiv      = tab.htmlDiv.find('div.' + moduleName),
      assentament  = [],
      gridData     = '',
      gridSource   = 
      {
        datatype: "json",
        datafields: [
          { name: 'ctcte', type: 'integer' },
          { name: 'ctdesc', type: 'string' },
          { name: 'deure', type: 'float' },
          { name: 'haver', type: 'float' },
          { name: 'data', type: 'date' },
          { name: 'com', type: 'string' }
        ],
        localdata: gridData
      };

  _this.htmlDiv = htmlDiv;
  _this.htmlGrid = _this.htmlDiv.find('#apuntsGrid');

  var apunt = new ApuntForm(tab);

  var create = function() {

    var reqType = 'POST',
        reqUrl  = '/assentaments';

    var cttext = _this.htmlDiv.find('input[name=cttext]').val();
    var data = {
      cttext: cttext,
      apunts: JSON.stringify(assentament)
    }

    $.ajax({
      url:  reqUrl,
      type: reqType,
      data: data,

      success: function(data) { },
      error:   function(data) { }
    });

  };

  var submit = function() {
    create();
  }

  var setBindings = function() {
    _this.htmlGrid.bind('rowdoubleclick', function (e) {
      var rowIndex = e.args.rowindex;

      apunt.editForm(rowIndex);
    });

    _this.htmlDiv.find('form').submit(function() {
      submit();
      return false;
    });
  };

  _this.fire = function() {
    _this.htmlDiv.jqxExpander({ showArrow: false, toggleMode: 'none' });
    apunt.newForm();

    var dataAdapter = new $.jqx.dataAdapter(gridSource);
    var grid = _this.htmlGrid.jqxGrid({
      width: '100%',
      //source: dataAdapter,
      theme: theme,
      sortable: true,
      pageable: true,
      columns: [
        { text: 'Data', datafield: 'data', width: 100 },
        { text: 'Compte', datafield: 'ctcte', width: 100 },
        { text: 'Descripcio', datafield: 'ctdesc', width: 250 },
        { text: 'Deure', datafield: 'deure', width: 100, cellsformat: 'C' },
        { text: 'Haver', datafield: 'haver', width: 100, cellsformat: 'C' },
        { text: 'Comentari', datafield: 'com', width: 310 }
      ]
      });

    setBindings();
  };

}

function ApuntForm(tab) {
  var _this = this;
      moduleName   = 'assentament',
      htmlDiv        = tab.htmlDiv.find('div.' + moduleName),
      tplAddApunt    = Handlebars.compile($('#tplAddApunt').html()),
      tplEditApunt   = Handlebars.compile($('#tplEditApunt').html()),
      tplApuntErrors = Handlebars.compile($('#tplApuntErrors').html());

  _this.htmlDiv = htmlDiv;
  _this.htmlGrid = _this.htmlDiv.find('#apuntsGrid');

  var getApunt = function() {
    return {
      ctcte:  _this.htmlDiv.find('input[name=ctcte]').val(),
      ctdesc: _this.htmlDiv.find('input[name=ctdesc]').val(),
      deure:  _this.htmlDiv.find('input[name=deure]').val(),
      haver:  _this.htmlDiv.find('input[name=haver]').val(),
      data:   _this.htmlDiv.find('input[name=data_apunt]').val(),
      com:    _this.htmlDiv.find('input[name=com_apunt]').val()
    }
  };

  var getDescripcio = function(ctcte) {
    $.ajax({
      url: '/assentaments/formatejarCompte',
      data: 'numCompte='+ctcte,
      success: function(data) {
        _this.htmlDiv.find('input[name=ctcte]').val(data.ctcte);
        _this.htmlDiv.find('input[name=ctdesc]').val(data.ctdesc);
      }
    });
  };


  _this.newForm = function() {
    _this.htmlDiv.find('div.fieldset-apunt').html(tplAddApunt());

    /* Add events */

    _this.htmlDiv.find('fieldset#addApunt div.save-apunt')
                 .click(function() {
                   addApunt();
                 });

    _this.htmlDiv.find('fieldset#addApunt input').each(function() {
      $(this).on('keydown', function(e) {
        if (e.which === 13) {
          addApunt();
          return false;
        }
      });
    });

    /* Default data */

    _this.htmlDiv.find('input[name=data_apunt]').val(currentDate());

    /* Bindings */

    _this.htmlDiv.find('input[name=data_apunt]').datepicker();

    _this.htmlDiv.find('input[name=ctcte]').on('keydown', function(e) { 
      var keyCode = e.keyCode || e.which; 

      if (keyCode == 9) { 
        getDescripcio($(this).val());
      }
    });

  };

  var addApunt = function() {
    var apunt = getApunt(),
        errors = validate(apunt);
  
    if (errors.length == 0) {
      assentament.push(apunt);
      _this.htmlGrid.jqxGrid('addrow', null, apunt);
      _this.newForm();
    }
  };

  _this.editForm = function(rowIndex) {

    var apunt = assentament[rowIndex];

    _this.htmlDiv.find('div.fieldset-apunt').html(
      tplEditApunt({
        index:  rowIndex,
        ctcte:  apunt.ctcte,
        ctdesc: apunt.ctdesc,
        deure:  apunt.deure,
        haver:  apunt.haver,
        data:   apunt.data,
        com:    apunt.com
      })
    );

    /* Update events */
    _this.htmlDiv.find('fieldset#editApunt div.save-apunt')
                 .click(function() {
                   update(rowIndex);
                 });

    _this.htmlDiv.find('fieldset#editApunt input').each(function() {
      $(this).on('keydown', function(e) {
        if (e.which === 13) {
          update();
          return false;
        }
      });

    });

    /* Destroy event */
    _this.htmlDiv.find('fieldset#editApunt div.destroy-apunt')
                 .click(function() {
                   destroy(rowIndex);
                 });

    /* Bindings */
    _this.htmlDiv.find('input[name=data_apunt]').datepicker();
  };

  var update = function(rowIndex) {
    var apunt = getApunt(),
        errors = validate(apunt);
  
    if (errors.length == 0) {
      assentament[rowIndex] = apunt;
      _this.htmlGrid.jqxGrid('updaterow', rowIndex, apunt);
      _this.newForm();
    }
  };

  var destroy = function(rowIndex) {
    assentament.splice(rowIndex,1);
    _this.htmlGrid.jqxGrid('deleterow', rowIndex);
    _this.newForm();
    _this.htmlDiv.find('div.apunt-errors').hide();
  };

  var validate = function(apunt) {
    var errors = [],
        tpldata = {};

    var apuntError = {
      field: {
        ctcte: 'Compte',
        ctdesc: 'Descripcio compte',
        deure: 'Deure',
        haver: 'Haver',
        deure_haver: 'Deure / Haver',
        data: 'Data'
      },

      lit: {
        blank: 'No pot estar buit',
        numeric: 'No es valor numeric',
        exist: 'No existeix'
      }
    };
  
    /* Compte */

    if (apunt.ctcte == '') {
      errors.push({
        field: apuntError.field.ctcte,
        lit:   apuntError.lit.blank
      });
    } else {
      if (!isInteger(parseInt(apunt.ctcte)))
        errors.push({
          field: apuntError.field.ctcte,
          lit:   apuntError.lit.numeric
        });
    }

    if (apunt.ctdesc == '')
      errors.push({
        field: apuntError.field.ctdesc,
        lit:   apuntError.lit.blank
      });

    /* Deure & Haver */

    if ((apunt.deure == '') && (apunt.haver == '')) {
      errors.push({
        field: apuntError.field.deure_haver,
        lit:   apuntError.lit.blank
      });
    }

    if (apunt.deure != '') {
      if (!isNumber(parseFloat(apunt.deure)))
        errors.push({
          field: apuntError.field.deure,
          lit:   apuntError.lit.numeric
        });
    } 

    if (apunt.haver != '') {
      if (!isNumber(parseFloat(apunt.haver)))
        errors.push({
          field: apuntError.field.haver,
          lit:   apuntError.lit.numeric
        });
    }

    /* Data */

    if (apunt.data == '')
      errors.push({
        field: apuntError.field.data,
        lit:   apuntError.lit.blank
      });

    if (errors.length > 0) {
      showErrorsTpl(errors);
    } else {
      _this.htmlDiv.find('div.apunt-errors').hide();
    }
    
    return errors;
  };

  var showErrorsTpl = function(errors) {
    _this.htmlDiv.find('div.apunt-errors').html(
      tplApuntErrors({ errors: errors })
    ).show();
  }

}
