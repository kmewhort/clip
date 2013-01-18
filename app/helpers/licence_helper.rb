module LicenceHelper
  def domains_comma_seperated(licence)
    domains = licence.attributes.map { |domain_name, is_in_domain| \
      (domain_name.match(/^domain/) && is_in_domain) ? domain_name.sub("domain_","") : "" }
    domains.reject { |str| str.empty? }.map { |str| "<strong>" + str + "</strong>" }.to_sentence.html_safe
  end

# categories for which licence information is available
  def licence_info_categories
    {
        :rights => 'Rights and Permissions',
        :obligations => 'Obligations',
        :copyleft_clauses => 'Copyleft / Share-alike',
        :disclaimers => 'Disclaimers',
        :changes_to_terms => 'Licence Versioning',
        :conflict_of_laws => 'Choice of Law / Choice of Forum'
    }
  end

  # links to other versions of this licence
  def licence_versions_nav(cur_licence)
    dd_tags = Licence.where(title: cur_licence.title).sort { |a,b| a.version <=> b.version }.map do |licence|
      content_tag 'dd', class: (licence == cur_licence ? "active" : "inactive") do
        link_to(licence.version, licence)
      end
    end
    dd_tags.join('')
    content_tag 'dl', class: "sub-nav" do
      content_tag('dt', "Versions:") + dd_tags.join('').html_safe
    end
  end
end