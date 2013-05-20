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
end