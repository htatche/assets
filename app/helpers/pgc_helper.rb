module PgcHelper

def display_pgc(categories)
  s = "<ul>"
  for category in categories
    s += "<li>"
    s += link_to category.pgcdes
    unless category.children.empty?
      s += display_pgc(category.children)
    end
    s += "</li>"
  end
  s += "</ul>"

  return s.html_safe
 end
end

# Funcio no utilitzada, la guardo perque el
# codi es interessant
def display_all(collection)
  html = ""
  html << content_tag(:ul, :class => "list") do
    collection.collect do |member|
      html << content_tag(:li) do
        member.pgcdes
      end
    end
  end

  return html.html_safe
end
##

