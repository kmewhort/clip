class Compatibility < ActiveRecord::Base
  belongs_to :licence
  attr_accessible :licence_id, :copyleft_compatible_with_future_versions, :copyleft_compatible_with_other,
                  :sublicense_future_versions, :sublicense_other

  # whether several works under different licences can be combined together under the target licence
  def self.compatible?(original_licences, target_licence, remix_type, reasons = {})
    # check the pair-wise compatibility with the target licence and combine the reasons
    result = true
    original_licences.each do |original_licence|
      if !original_licence.compatibility.compatible_with? target_licence, remix_type, false, reasons
        result = false
      end
    end
    result
  end

  # This licence is compatible with another if a derivative work can be licenced under the other licence
  # (but not necessarily licenced under this licence, if it's only one-way compatible);
  # If accept_soft_compatibility is true, the licence is also considered compatible if a combined work can
  # satisfy the licence terms through releasing the work under a licence containing the terms of BOTH licences
  def compatible_with?(other_licence, remix_type = 'strong_adaptation', soft_compatibility_acceptable = false, reasons = {})
    # reasons for any soft or hard incompatibility
    reasons[:soft] = [] if reasons[:soft].nil?
    reasons[:hard] = [] if reasons[:hard].nil?
    reasons[:warnings] = [] if reasons[:warnings].nil?

    #
    # Basic compatibility checks/barriers
    #

    # if no modification is allowed, cannot create a compatible derivative work at all (and, with
    # this full-stop, no further incompatibility checks necessary)
    if !licence.right.right_to_modify && (remix_type != 'collection')
      reasons[:hard] << "#{licence.identifier} prohibits any type of adaptation"
      return false
    end

    # compatible with the exact same licence,
    return true if self.licence == other_licence

    # future versions of the same licence
    return true if (copyleft_compatible_with_future_versions || sublicense_future_versions) &&
                   (licence.all_versions.to_a.include?(other_licence) &&
                    licence.all_versions.index(other_licence) > licence.all_versions.index(licence))

    # specifically-defined compatibility
    return true if !copyleft_compatible_with_other.nil? && copyleft_compatible_with_other.split(/\s*,\s*/).include?(other_licence.identifier)
    return true if !sublicense_other.nil? && sublicense_other.split(/\s*,\s*/).include?(other_licence.identifier)

    #
    # Copyleft checks
    #

    # for remixing into a collection, only check needed is that there's no
    # contractual copyleft obligation against including the work in a collection
    if remix_type == 'collection'
      if licence.obligation.obligation_copyleft &&
         (licence.copyleft_clause.copyleft_applies_to == "compilations")
        reasons[:hard] << "#{licence.identifier} contains a copyleft clause which contractually applies even to collections. A collection can only be released under the same #{licence.identifier} licence"
        return false
      end
      return true
    end


    # unless explicitly compatible above checks, the licence is NOT compatible where
    # this licence has an applicable copyleft clause
    if licence.obligation.obligation_copyleft
      unless (remix_type == 'weak_adaptation_of_files' &&
              licence.copyleft_clause.copyleft_applies_to == "modified_files") ||
             (remix_type == 'weak_adaptation_of_libraries' &&
              licence.copyleft_clause.copyleft_applied_to == "derivatives_linking_excepted")
        reasons[:hard] << "#{licence.identifier} contains a copyleft clause and adapations can only be released under the same #{licence.identifier} licence"
        return false
      end
    end

    #
    # Term-by-term comparisons
    #

    # consider permissive licences compatible where the other licence includes all of the core obligations
    # of this one (the combined work is still technically under the terms of BOTH licences,
    # but a user's compliance with the more onerous licence implies compliance with the other)
    self.licence.obligation.attributes.each_pair do |key, value|
      next unless !key.match(/\Aobligation/).nil? && value && !other_licence.obligation.attributes[key]
      reasons[:soft] << "#{licence.identifier} contains #{nicify(key)} obligations, but #{other_licence.identifier} does not"
      # TODO: add a warning for soft compatibility
      # TODO: more specific checks for type of attribution, type of copyleft
    end

    # the other licence cannot grant any additional rights or permissions
    other_licence.right.attributes.each_pair do |key, value|
      next unless !key.match(/\A(right|covers)/).nil? && value && !licence.right.attributes[key]

      # explicit permission for circumventions or SGDRs is jurisdiction specific and a
      # licence not including these does not necessarily mean the licence does not allow it;
      # thus, generate a warning only
      if key == "covers_circumventions"
        reasons[:warnings] << "#{licence.identifier} does not explicitly permit circumvention of technical protection measures (TPMs), but #{other_licence.identifier} \
          grants permission to do so. This may render the licences incompatible in jurisdictions with anti-circumvention laws"
      elsif key == "covers_sgdrs"
        reasons[:warnings] << "#{licence.identifier} does not explicitly grant Sui Generis Database Rights (SGDRs), but #{other_licence.identifier} \
          does. This may render the licences incompatible in jurisdictions with legislated SGDRs (such as in Europe)"
      # a patent licence may be implicit even if not set out explicitly in the licence;
      # thus, generate a warning only
      elsif key == "covers_patents_explicitly"
        reasons[:warnings] << "#{licence.identifier} does not explicitly cover patent rights, but #{other_licence.identifier} \
          does. However, depending on the context, this may not pose a problem if patent rights are implicitly granted in the #{licence.identifier} licence"
      else
        reasons[:soft] << "#{licence.identifier} does not cover #{nicify(key)}, but #{other_licence.identifier} #{!key.match(/\Aright/).nil? ? 'grants this right' : 'does'}"
      end
    end

    # the other licence cannot remove any prohibitions (unless soft compatibility is acceptable,
    # such that the prohibitions can be included in a combined licence)
    other_licence.right.attributes.each_pair do |key, value|
      next unless !key.match(/\A(prohibits)/).nil? && !value && licence.right.attributes[key]
      reasons[:soft] << "#{licence.identifier} prohibits #{nicify(key)}, but #{other_licence.identifier} does not contain any such stipulation"
    end

    reasons[:hard].empty? && (reasons[:soft].empty? || soft_compatibility_acceptable)
  end

  def as_json(options = {})
    super( except: [ :id, :licence_id, :created_at, :updated_at ] )
  end

  private
  # nicify json attributes for incompatibility reason messages
  def nicify(attribute)
    attribute.sub(/\A(covers)|(prohibits)|(right)|(obligation)_/,'').gsub(/_/,' ')
  end

end
