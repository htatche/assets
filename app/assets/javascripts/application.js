//= require jquery
//= require jquery_ujs
//= require jquery.ui.all
//= require jquery.ui.datepicker-ca
//= require ../../../vendor/assets/javascripts/underscore-min.js
//= require ../../../vendor/assets/javascripts/backbone-min.js
//= require_tree ../../../vendor/assets/javascripts/
//= require_tree .

// jquery-ui defaults
$.datepicker.setDefaults( $.datepicker.regional['ca'] );

$(document).ready(function() {
	theme = getTheme();

  $('#appTabs').jqxTabs({ position: 'top', theme: theme, showCloseButtons: true });

  inputToNumeric = function(numeric, input, width, height) {

    numeric.jqxNumberInput({ symbol: '€',
                             groupSeparator: '',
                             decimalSeparator: ',',
                             promptChar: ' ',
                             digits: '8',
                             symbolPosition: 'right',
                             width: width,
                             height: height,
                             theme: theme });

    numeric
      .find('input')
      .attr({name: input.attr('name'),
             class: input.attr('class'),
             tabindex: input.attr('tabindex')});

    numeric.show();
    input.remove();
  };

});
