module ApplicationHelper
  def icon(type)
    content_tag 'span', '', class: "glyphicon glyphicon-#{type}"
  end
end
