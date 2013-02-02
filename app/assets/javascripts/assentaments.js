/*
$(document).ready(function () {
  $("#nou_assentament").jqxExpander({ showArrow: false, toggleMode: 'none' });

  $('#numCompte').live('keydown', function(e) { 
    var keyCode = e.keyCode || e.which; 
    if (keyCode == 9) { 

      $.ajax({
        url: '/assentaments/fillCtcteInput',
        data: 'numCompte='+$(this).val(),
        success: function(data) {
          var data = jQuery.parseJSON(data);

          $('#numCompte').val(data.ctcte);
          $('#descrCompte').val(data.ctdesc);
        }
      });
    }
  });

  $('#dataApunt').datepicker();
});

*/

function AssentamentForm (tab) {
  var _this = this;

  var moduleName = 'assentament',
      htmlDiv    = tab.htmlDiv.find('div.' + moduleName);


  _this.fire = function() {
    htmlDiv.jqxExpander({ showArrow: false, toggleMode: 'none' });
  };

}
