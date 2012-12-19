$(document).ready(function () {
  $("#create_apunt_form").bind("ajax:success", function(evt, data, status, xhr) {
    $('#apunts').html(xhr.responseText);
  })
});
