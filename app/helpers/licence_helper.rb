module LicenceHelper
  def search_tabs
    { "/licences" => "All licences",
      "/licences?domain_data=true" => "Data",
      "/licences?domain_software=true" => "Software",
      "/licences?domain_content=true" => "Content",
      "/licences?maintainer_type=ngo,private" => "International",
      "/licences?maintainer_type=gov" => "Government"
    }.map do |url, link_name|
        content_tag :li, id: (url == request.fullpath ? "current" : nil) do
          content_tag :a, link_name, href: url
        end
    end.join.html_safe
  end

  def licence_tabs
    tabs = {}
    tabs['licence_info'] = "Licence Info"
    tabs['licence_text'] = "Legal Text"
    tabs['licence_compatibility'] = "Compatibility"
    tabs['licence_benchmarks'] = "Benchmarks"
    tabs['licence_risks'] = "Risks"
    tabs['licence_comparison'] = "History" if !@family_trees.nil? && !@family_trees.empty?
    tabs['licence_metadata'] = "Metadata"
    tabs
  end

  def domains_comma_seperated(licence)
    domains = licence.attributes.map { |domain_name, is_in_domain| \
      (domain_name.match(/^domain/) && is_in_domain) ? domain_name.sub("domain_","") : "" }
    domains.reject { |str| str.empty? }.map { |str| "<strong>" + str + "</strong>" }.to_sentence.html_safe
  end

# categories for which licence information is available
  def licence_info_categories(licence)
    # return applicable categories of licence information
    result = {}
    result[:rights] = 'Rights and Permissions'
    result[:obligations] = 'Obligations'
    result[:attribution_clauses] = 'Attribution' if licence.obligation.obligation_attribution
    result[:copyleft_clauses] = 'Copyleft / Share-alike' if licence.obligation.obligation_copyleft
    result[:disclaimers] = 'Disclaimers'
    result[:terminations] = 'Termination'
    result[:changes_to_terms] = 'Licence Versioning'
    result[:conflict_of_laws] = 'Choice of Law / Choice of Forum'
    result
  end

  # links to other versions of this licence
  def licence_versions_nav(cur_licence)
    versions = cur_licence.all_versions
    unless versions.empty?
      dd_tags = cur_licence.all_versions.map do |licence|
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

  # populate array of rights covered / not covered under the licence
  def rights_covered(rights, covered = true)
    result = []
    result << "Copyright" if rights.covers_copyright == covered
    result << "Trade-marks" if rights.covers_trademarks == covered
    result <<  (covered ? "Patents" : "Patents (unless rights are implied by the licence)") \
      if rights.covers_patents_explicitly == covered
    result << "Neighbouring rights (rights in a sound recording or performance)" \
      if rights.covers_neighbouring_rights == covered
    result << "Database rights (where applicable under European law)" if rights.covers_sgdrs
    result << "Moral rights" if rights.covers_moral_rights
    result << "Prohibitions against circumvention of technical protection measures" \
      if !rights.covers_circumventions && !covered # circumvention is only a prohibition, so only show if not covered
    result
  end
end