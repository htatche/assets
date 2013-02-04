/* PGC module 
   
   params:
    tab (parent tab widget)
    subgrup (subgrup root) Optional
*/

function Pgc (tab, subgrup) {
  var _this = this;

  var source
      ,dataAdapter
      ,pgcTree 
      ,bAddGrup 
      ,bAddSubgrup 
      ,bAddCompte
      ,bEdit
      ,bRemove 
      ,treeRoute = '/pgcs/tree'

  var moduleName = 'pgcs',
      htmlDiv    = tab.htmlDiv.find('div.' + moduleName);

  _this.htmlDiv = htmlDiv;

  _this.cleanFormErrorState = function(frm) {
    frm.find("div.validation-error")
      .html("")
      .hide();

    frm.find("input").removeClass('ui-state-error');
  }

  _this.cleanFormInputs = function(frm) {
    frm.find("input[type=text]").val('');
  }

  _this.showValidationErrors = function(dialog, xhr) {
    var errors,
        errorText;

    try {
      errors = $.parseJSON(xhr.responseText);
    } catch(err) {
      errors = {message: "Sisplau refresqui la pagina i torni a probar"};
    }

    errorText = "<p><span class='ui-icon ui-icon-alert' style='float: left; margin-right: .3em;'></span>"
    errorText += "<strong>Verifiqui els seguents errors:</strong> \n<ul>";

    for ( error in errors ) {
      var pattern = new RegExp("\\[.*("+error+")\\]$");

      errorText += "<li>" + error + ': ' + errors[error] + "</li> ";
      $('form input').filter(function() {return this.name.match(pattern)}).addClass( "ui-state-error" );
    }

    errorText += "</ul>";

    dialog.find('div.validation-error')
      .html(errorText)
      .addClass("ui-state-error ui-corner-all")
      .effect("highlight", {color: '#FFAAAA'}, 500);
  }

  /* Enables each button depending on category and child objects */
  _this.refreshTreeButtonsState = function(category, childCategories, childComptes) {
    if (category == 2) {
      bAddCompte.button({disabled: true });
      bAddSubgrup.button({disabled: true });
    }
    else if (category == 0) {
      bAddCompte.button({disabled: true });
      bAddSubgrup.button({disabled: false });
    } else {
      if (childCategories == false && childComptes == false) {
        bAddCompte.button({disabled: false });
        bAddSubgrup.button({disabled: false });
      } else if (childCategories == false && childComptes == true) {
        bAddCompte.button({disabled: false });
        bAddSubgrup.button({disabled: true });
      } else if (childCategories == true && childComptes == false) {
        bAddCompte.button({disabled: true});
        bAddSubgrup.button({disabled: false });
      }
    }
  }

  _this.loadDialog = function(url, tag) {
    var item = pgcTree.jqxTree('selectedItem').element;

    $.ajax({
      url: url,
      data: 'id='+item.id,
      // Set to false, otherwise fields are not modified after firing load(Dialog),
      // because the div is ont already loaded.
      async: false,
      success: function(data) {
        tag.html(data).dialog({
          autoOpen: false,
          height: "auto",
          width: "auto",
          autoResize:true,
          resizable: false,
          modal: true,
          close: function() {
            _this.cleanFormErrorState(tag.find('form'));
            _this.cleanFormInputs(tag.find('form'));
          }
        }).dialog('open');
      }
    });
  }

  _this.fire = function() {
    pgcTree = $("#pgcTree");
    bAddGrup = $('#bAddGrup');
    bAddSubgrup = $('#bAddSubgrup');
    bAddCompte = $('#bAddCompteToTree');
    bEdit = $('#bEditItemFromTree');
    bRemove = $('#bRemoveFromTree');

    if (subgrup)
      treeRoute = treeRoute+'/'+subgrup;

    source =
    {
      datatype: "json",
      datafields: [
          { name: 'id' },
          { name: 'parent_id' },
          { name: 'pgcdes' }
      ],
      url: treeRoute,
    };

    dataAdapter = new $.jqx.dataAdapter(
        source,
        { loadComplete: function() {
            var records = dataAdapter.getRecordsHierarchy(
              'id',
              'parent_id',
              'items',
              [{ name: 'pgcdes', map: 'label'}]
            );

            pgcTree.jqxTree({
              source: records,
              height: 'auto',
              width: '700px'
            });

            pgcTree.jqxTree('selectItem', pgcTree.find('li:first')[0]);

            $("#pgcTreeLoading").hide();
            pgcTree.show();
          }
        }
    );

    /* Create jqxExpander */
    _this.htmlDiv.jqxExpander({ showArrow: false, toggleMode: 'none' });

    /* Load jqxTree for PGC */
    $("#pgcTreeLoading").show();
    pgcTree.hide();
    dataAdapter.dataBind();

    /* We reload all buttons state every time an item */
    /* of tree is selected */
    pgcTree.bind('select', function (event) { 
      var args = event.args;
      var item = pgcTree.jqxTree('getItem', args.element);

      $.ajax({
        url: '/pgcs/getTreeItemCategory',
        data: 'id='+item.id,
        success: function(data) {
          _this.refreshTreeButtonsState(data["category"], data["childCategories"], data["childComptes"]);
        },
        error: function(data) {
          alert("Siusplau, refresqui la pagina");
        }
      });
        
    }); 

    /* Build PGC Tree options menu */

    bAddGrup
      .button({
        icons: {
          primary: "ui-icon-plus"
        }
      })
      .click(function () {
        var url = '/pgcs/new/grup',
            tag = jQuery('<div/>', {
                    id: 'addGrupDialog',
                    class: 'pgcDialog',
                    title: 'Crear nou grup comptable' });

        _this.loadDialog(url, tag);

        tag
          .bind("ajax:success", function(evt, data, status, xhr) {
            var data = jQuery.parseJSON(data);
            var name = data.pgccte + " - " + data.pgcdes;

            tag.dialog('close');
            pgcTree.jqxTree('addTo', { label: name, id: data.id });
            pgcTree.jqxTree('render');
          })
          .bind("ajax:error", function(evt, xhr, status, error){
            _this.cleanFormErrorState(tag.find('form'));
            _this.showValidationErrors(tag, xhr);
          });
      });

    bAddSubgrup
      .button({
        icons: {
          primary: "ui-icon-plus"
        }
      })
      .click(function () {
        var url = '/pgcs/new/subgrup',
            tag = jQuery('<div/>', {
                    id: 'addSubgrupDialog',
                    class: 'pgcDialog',
                    title: 'Crear nou subgrup comptable' }),
            selectedItem = pgcTree.jqxTree('selectedItem'),
            item = pgcTree.find("li[id="+ selectedItem.id +"]");

        if (selectedItem.element != null) {
          _this.loadDialog(url, tag);

          tag.find("form input[name='parent']").val(item.children('div').children('span').html());
          tag.find("form input[name='parent_id']").val(selectedItem.id);
        } 

        tag
          .bind("ajax:success", function(evt, data, status, xhr) {
            var data = jQuery.parseJSON(data),
                name = data.pgccte + " - " + data.pgcdes;

            tag.dialog('close');
            pgcTree.jqxTree('addTo', { id: data.id, html: "<span name='grup'>" + name + "</span>"}, selectedItem.element, true);
            pgcTree.jqxTree('render');
          })
          .bind("ajax:error", function(evt, xhr, status, error){
            _this.cleanFormErrorState(tag.find('form'));
            _this.showValidationErrors(tag, xhr);
          });
      });

    bAddCompte
      .button({
        icons: {
          primary: "ui-icon-plus"
        }
      })
      .click(function () {
        var url = '/comptes/new',
            tag = jQuery('<div/>', {
                    id: 'addCompteDialog',
                    class: 'pgcDialog',
                    title: 'Crear nou compte comptable' }),
            selectedItem = pgcTree.jqxTree('selectedItem'),
            item = pgcTree.find("li[id="+ selectedItem.id +"]");

        if (selectedItem.element != null) {
          _this.loadDialog(url, tag);

          tag.find("form input[name='subgrup']").val(item.children('div').children('span').html());
          tag.find("form input[name='compte[pgc_id]']").val(selectedItem.id);
        } 

        tag
          .bind("ajax:success", function(evt, data, status, xhr) {
            var data = jQuery.parseJSON(data),
                name = data.ctcte + " - " + data.ctdesc;

            tag.dialog('close');
            pgcTree.jqxTree('addTo', { id: data.ctcte, html: "<span name='compte'>" + name + "</span>"}, selectedItem.element, true);
            pgcTree.jqxTree('render');
          })
          .bind("ajax:error", function(evt, xhr, status, error){
            _this.cleanFormErrorState(tag.find('form'));
            _this.showValidationErrors(tag, xhr);
          });
      });

    bEdit
      .button({
        icons: {
          primary: "ui-icon-pencil"
        }
      })
      .click(function () {
        var tag = jQuery('<div/>', {
                    id: 'editGroupDialog',
                    class: 'pgcDialog',
                    title: 'Modificar compte comptable' }),
            item = pgcTree.jqxTree('selectedItem'),
            itemType = pgcTree.find("li[id="+ item.id +"]").children('div').children('span').attr('name'),
            parentItem = pgcTree.find("li[id="+ item.id +"]").parent().parent();

        if (item.element != null) {

          if (itemType == 'grup') {
            url = '/pgcs/' + item.id + '/edit';
            inputNameParent = 'parent';
            inputNameParentId = 'parent_id';
          } else {
            url = '/comptes/' + item.id + '/edit';
            inputNameParent = 'subgrup';
            inputNameParentId = 'pgc_id';
          }

          _this.loadDialog(url, tag);

          tag.find("form input[name='"+inputNameParent+"']").val(parentItem.children('div').children('span').html());
          tag.find("form input[name='"+inputNameParentId+"']").val(parentItem.attr('id'));
        } 

        tag
          .bind("ajax:success", function(evt, data, status, xhr) {
            var data = jQuery.parseJSON(data),
                name = data.pgccte + " - " + data.pgcdes;
                element = pgcTree.find('li[id='+item.id+']');

            if (itemType == 'grup') {
              name = data.pgccte + " - " + data.pgcdes;
            } else {
              name = data.ctcte + " - " + data.ctdesc;
            }

            element.children('div').children('span').text(name);
            tag.dialog('close');
            pgcTree.jqxTree('render');
          })
          .bind("ajax:error", function(evt, xhr, status, error){
            _this.cleanFormErrorState(tag.find('form'));
            _this.showValidationErrors(tag, xhr);
          });

      });

    bRemove
      .button({
        icons: {
          primary: "ui-icon-trash"
        }
      })
      .click(function () {
        var url = '/pgcs/delete',
            tag = jQuery('<div/>', {
                    id: 'deleteDialog',
                    class: 'pgcDialog',
                    title: 'Eliminar compte comptable' }),
            item = pgcTree.jqxTree('selectedItem'),
            itemType = pgcTree.find("li[id="+ item.id +"]").children('div').children('span').attr('name');

        if (item.element != null) {

          if (itemType == 'grup') {
            url = '/pgcs/';
          } else {
            url = '/comptes/';
          }

          $.ajax({
            url: url + 'delete',
            data: 'id='+item.id,
            success: function(data) {
              tag.html(data).dialog({
                autoOpen: false,
                resizable: false,
                width:400,
                height:150,
                modal: true,
                buttons: {
                  "Eliminar": function() {
                    $.ajax({
                      url: url + item.id,
                      type: 'DELETE',
                      success: function(data) {
                        tag.dialog('close');
                        pgcTree.jqxTree('removeItem', item.element);
                      },
                      error: function(data) {
                        tag.dialog('close');
                      }
                    });
                  },
                  "Cancelar": function() {
                    $(this).dialog('close');
                  }
                }
              }).dialog('open');
            }
          });
        } 

        tag
          .bind("ajax:success", function(evt, data, status, xhr) {
            var data = jQuery.parseJSON(data),
                name = data.pgccte + " - " + data.pgcdes;
                element = pgcTree.find('li[id='+item.id+']');

            tag.dialog('close');
            pgcTree.jqxTree('render');
          })
          .bind("ajax:error", function(evt, xhr, status, error){
            _this.cleanFormErrorState(tag.find('form'));
            _this.showValidationErrors(tag, xhr);
          });
      });

  }
}



