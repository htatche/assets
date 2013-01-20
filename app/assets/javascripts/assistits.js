function Assistit(tab, el) {
  var _this = this;
  var  _tNumdoc,
       _tCtekey,
       _tCtdesc = el.find('input[name=ctdesc]');

  _opckey = el.attr('id');

  _this.getFacturaDuplicada = function(numdoc, ctekey, opckey) {
    if (_tNumdoc.val() && _tCtekey.val()) {
      el.find('#factura-duplicada').remove();
      $.get('/assistits/getFacturaDuplicada',
            { numdoc: numdoc,
              ctcte: ctekey,
              opckey: opckey
            },
        function(data) {
          if (data) {
            var dialog = data;
            var errmsg;
            
            errmsg = '<div id="factura-duplicada" class="input-validation-error">';
            errmsg += 'Aquesta factura ja existeix, <a href="#"> Mostrar </a>';
            errmsg += '</div>';
            
            el.find('#factura-duplicada').remove();
            el.find('input[name=numdoc]').after(errmsg);
            el.find('#factura-duplicada').fadeIn('fast');
            el.find('#factura-duplicada a').click(function() {
              $(dialog).dialog({
                autoOpen: false,
                height: "auto",
                width: "auto",
                autoResize:true,
                resizable: false,
                modal: true,
                close: function() {
                }
              }).dialog('open');
            });
          } else {
            el.find('#factura-duplicada').remove();
          }
        });
    }
  };

  _this.getComptes = function() {
    $.get('/getComptes',
          {opckey: _opckey},
          function(data) {
            combobox = el.find('div.ctcte-combobox').jqxComboBox({
              source: data,
              width: '230px',
              height: '25px',
              dropDownWidth: '300px',
              theme: theme });

            combobox.find('input').attr({tabindex: '2', name: 'ctekey'});
            combobox.find('input').css({padding: '2px'});
            _tNumdoc = el.find('input[name=numdoc]');
            _tCtekey = el.find('input[name=ctekey]');
            _this.setBindings();
            _this.setTabindexes();
    });
  };

  _this.getCodiCompte = function(ctcte, errtpl, input) {
    el.find('.error-compte').remove();

    $.getJSON('/assistits/getCodiCompte',
      {opckey: _opckey,
       ctcte: ctcte},
      function(data) {
        _tCtekey.val(data.ctcte);
        _tCtdesc.val(data.ctdesc);
    })
    .error(function() {
      var template = _.template(
        $(errtpl).html() 
      );

      var tpldata = {
        ctcte: _tCtekey.val(),
        ctdesc: _tCtdesc.val()
      };
      
      el.find(input).after(
        template(tpldata)
      );

      el.find('.error-compte').fadeIn('fast');
    })
    .complete(function() {
        _this.getFacturaDuplicada(_tNumdoc.val(),
                                  _tCtekey.val(),
                                  _opckey);
    });
  };

  _this.reload = function() {
    $.get('/assistit/' + _opckey, function (data) {
      tab.find('.content').html(data);
        assistit = tab.find('.assistit');
        _this.assistit = new Assistit(tab, assistit);
        _this.assistit.fire();
    });
  };

  _this.submit = function() {
    el.find('form div.errors')
           .html('')
           .hide();

    $.post(
      '/assistits',
      params = el.find('form').serialize(),
      function(data) {
        tab.find('content');
/*
        el.find('form div.notice')
          .html(data)
          .fadeIn(1000)
          .fadeOut(1000);
*/

        _this.reload();
      }
    ).error(function(err) {
      var errors = jQuery.parseJSON(err.responseText);

      _.templateSettings.variable = "rc";

      var template = _.template(
        $('script.tpl-assistit-errors').html() 
      );

      var tpldata = {errors: errors};
      
      el.find('form div.errors')
        .html(template(tpldata))
        .addClass('ui-state-error ui-corner-all')
        .effect('highlight', {color: '#FFAAAA'}, 500);

      el.find('form div.errors').fadeIn('fast');
    });
  };

  _this.setTabindexes = function() {
    el.find('form input,select').each(function(index) {
      $(this).attr('tabindex', index);
    });
  };

  _this.setBindings = function() {

    _tNumdoc.blur(function() {
        items = _this.getFacturaDuplicada(_tNumdoc.val(),
                                          _tCtekey.val(),
                                          _opckey);
    });

    $.each([_tCtekey, _tCtdesc], function() {
      this.blur(function() {
        el.find('.error-compte').remove();

        if (_tCtekey.val() && _tCtdesc.val()) {
          _this.getCodiCompte(_tCtekey.val(),
                              'script.tpl-error-1',
                              'div.ctcte-combobox');
        } else if (_tCtekey.val() && _tCtdesc.val() === '') {
          _this.getCodiCompte(_tCtekey.val(),
                              'script.tpl-error-2',
                              'input[name=ctdesc]');
        } else if (_tCtekey.val() === '' && _tCtdesc.val()) {
          _this.getCodiCompte(_tCtekey.val(),
                              'script.tpl-error-3',
                              'div.ctcte-combobox');
        }
      });


    });

    el.find('input[name=comment]').blur(function() {
      fieldset = el.find('fieldset#assentaments');
      var nrows = _this.assentament.nrows(fieldset);

      if (nrows == 1) {
        fieldset.find('input.import')
          .val(el.find('fieldset.main input[name=import]').val());
        fieldset.find('input.comment')
          .val(el.find('fieldset.main input[name=comment]').val());
      }
    });

    el.find('div.ctcte-combobox').bind('select', function() {
        _this.getCodiCompte(_tCtekey.val());
    });

    el.find('form').submit(function() {
      _this.submit();
      
      /* Cancel primary submit action (.preventDefault()) */
      return false;
    });
  };

  _this.fire = function() {
    el.jqxExpander({ showArrow: false, toggleMode: 'none' });
    inputToNumeric(el.find('fieldset.main div.numeric'),
                   el.find('fieldset.main input.import'),
                   '230px',
                   el.find('fieldset.main input.import').attr('height'));
    el.find('div.numeric').find('input').attr({tabindex: '5',
                                               name: 'import'});

    _this.assentament = new Assentament(el);

    _this.getComptes();
  };
  
}

function Assentament(el) {
  var _this = this;
  _opckey = el.attr('id');

  _this.initialize = function() {
    _this.bindings();
  };

  _this.bindKeydown = function(fieldset) {
    fieldset.find('input:last').unbind('keydown.newrow');
    fieldset.find('input:last').on('keydown.newrow', function(e) {
      if(e.which === 13) {
        fieldset = $(this).parents('fieldset');
        _this.getRow(fieldset);
        $(this).unbind('keydown');

        return false;
      }
    });
  };

  _this.bindings = function() {
  
    el.find('fieldset:not(.main)').each(function() {
      _this.bindDestoyIcon($(this));
    });

    el.find('fieldset:not(.main)').each(function() {
      inputToNumeric($(this).find('div.numeric'),
                     $(this).find('input.import:last'),
                     '100px',
                     '28px');
    });
    el.find('fieldset:not(.main)').each(function() {
      _this.bindKeydown($(this));
    });

  };

  _this.nrows = function(fieldset) {
    return fieldset.find('table>tbody>tr').length;
  };

  _this.setTabindexes = function() {
    el.find('form input,select').each(function(index) {
      $(this).attr('tabindex', index);
    });
  };

  _this.bindDestoyIcon = function(fieldset) {
    fieldset.find('tr:last td.destroy span')
      .click(function() {
        if (fieldset.find('table tbody tr').length > 1) {
          $(this).parents('tr').remove();
          _this.bindKeydown(fieldset);
          _this.setTabindexes();
        }
      });
  };

  _this.getRow = function(fieldset) {
    id = fieldset.attr('id');

    if (id == 'assentaments') {
      action = 'getAssentament';
    }
    else if (id == 'impostos') {
      action = 'getImpost';
    }
    else if (id == 'pagaments') {
      action ='getPagament';
    }

    $.get(
      '/assistits/' + action,
      {opckey: _opckey,
       nrows: _this.nrows(fieldset)},
      function(data) {
        _this.setRow(fieldset, data);
      }
    );
  };

  _this.setRow = function(fieldset, data) {
    $(data).appendTo(fieldset.find('table>tbody'));

    inputToNumeric(fieldset.find('input.import:last').next('div.numeric'),
                   fieldset.find('input.import:last'),
                   '100px',
                   '28px');
    fieldset.find('select:last').focus();
    _this.bindDestoyIcon(fieldset);
    _this.bindKeydown(fieldset);
    _this.setTabindexes();
  };

  _this.initialize();
}
