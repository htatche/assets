var Assentament = Backbone.Model.extend({
  defaults: {
  }
});

var Contrapartida = Backbone.Collection.extend({
  model: Assentament
});

var AssentamentView = Backbone.View.extend({ 
  tagName: 'span',
  className: 'assentament-wrap',
  template: $('tpl-assentament').html(),

  render: function() {
    var tpl = _.template(this.template);
    this.$el.html(tpl(this.model.toJSON()));
  }
});
