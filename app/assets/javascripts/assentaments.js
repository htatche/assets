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
  /*
  $('#numCompte').keypress(function(evt) {
    if (evt.which == 0) {
      $.ajax({
        url: '/assentaments/tbNumCompte_fill',
        data: 'numCompte='+$(this).val(),
        success: function(data) {
          $('#numCompte').val(data["compte"]);
          $('#frmErrors').html(data["frmErrors"]);
        }
      });
    }
  });
  */

  $('#dataApunt').datepicker();
});
