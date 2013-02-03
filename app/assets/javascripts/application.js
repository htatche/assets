//= require jquery
// UJS desactivat perque tarda massa en carregar en entorn dev
//= require jquery_ujs
//= require jquery.ui.button
//= require jquery.ui.dialog
//= require jquery.effects.all
//= require jquery.ui.datepicker-ca
//= require ../../../vendor/assets/javascripts/underscore-min.js
//= require ../../../vendor/assets/javascripts/backbone-min.js
//= require ../../../vendor/assets/javascripts/jqwidgets/globalization/jquery.global.js
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
                             negativeSymbol: '-',
                             min: -99999999,
                             max: 999999999,
                             symbolPosition: 'right',
                             width: width,
                             height: height,
                             theme: theme });

    numeric.find('input')
      .attr({name: input.attr('name'),
             class: input.attr('class'),
             tabindex: input.attr('tabindex')});

    numeric.jqxNumberInput('val', input.val());

    numeric.show();
    input.remove();
  };
  
  isInteger = function(n) {
    return n===+n && n===(n|0);
  };

  isFloat = function(n) {
    return n===+n && n!==(n|0);
  };

  isNumber = function(n) {
    return isInteger(n) || isFloat(n);
  };

  currentDate = function() {
    var today = new Date(),
        day = today.getDate(),
        month = today.getMonth() + 1,
        year = today.getFullYear();

    return day + '/' + month + '/' + year;
  };
});
