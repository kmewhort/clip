module CompatibilityHelper
  def wrapped_cells(data, max_cols = 6)
    html = "<table>"
    num_rows = (data.length.to_f / max_cols).ceil
    for j in 0..(num_rows-1)
      html << "<tr>"
      num_cells = (j != (num_rows-1)) ? max_cols : (data.length % max_cols)
      for i in 0..(num_cells-1)
        html << "#{data[j*max_cols + i]}"
      end
      html << "</tr>"
    end
    html << "</table>"
    html.html_safe
  end

  def incompatibility_reasons_tooltip(other_licence, reasons)
    all_reasons = reasons[:hard] + reasons[:soft]

    html = ""
    if all_reasons.empty?
      html << "<span class='licence-title'><strong>#{h other_licence.full_title}</strong> is <strong>compatible.</strong>"
    else
      html << "<span class='licence-title'><strong>#{h other_licence.full_title}</strong> is <strong>incompatible</strong> for the following reasons:"
      html << "<ul>"
      all_reasons.each do |reason|
        html << "<li class='reason'>#{reason + ((reason == all_reasons.last) ? "." : ";")}</li>"
      end
      html << "</ul>"
    end
    html.html_safe
  end
end