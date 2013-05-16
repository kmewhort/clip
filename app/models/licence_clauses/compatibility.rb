class Compatibility < ActiveRecord::Base
  belongs_to :licence
  attr_accessible :licence_id, :copyleft_compatible_with_future_versions, :copyleft_compatible_with_other,
                  :sublicense_future_versions, :sublicense_other

  # This licence is compatible with another if a derivative work can be licenced under the other licence
  # (but not necessarily licenced under this licence, if it's only one-way compatible);
  # If accept_soft_compatibility is true, the licence is also considered compatible if a combined work can
  # satisfy the licence terms through releasing the work under a licence containing the terms of BOTH licences
  def compatible_with?(other_licence, soft_compatibility_acceptable = false)
    # if no modification is allowed, cannot create a compatible derivative work at all
    return false if !licence.right.right_to_modify

    # compatible with the exact same licence,
    return true if self.licence == other_licence

    # future versions of the same licence
    return true if (copyleft_compatible_with_future_versions || sublicense_future_versions) &&
                   (other_licence.title == self.licence.title && other_licence.version >= self.licence.version)

    # specifically-defined compatibility
    return true if !copyleft_compatible_with_other.nil? && copyleft_compatible_with_other.split(/\s*,\s*/).include?(other_licence.id)
    return true if !sublicense_other.nil? && sublicense_other.split(/\s*,\s*/).include?(other_licence.id)

    # unless explicitly compatible per above checks, the licence is NOT compatible where
    # this licence has a copyleft clause
    # TODO: check type of combination / type of copyleft
    return false if self.licence.obligation.obligation_copyleft?

    # consider permissive licences compatible where the other licence includes all of the core obligations
    # of this one (the combined work is still technically under the terms of BOTH licences,
    # but a user's compliance with the more onerous licence implies compliance with the other)
    self.licence.obligation.attributes.each_pair do |key, value|
      next unless key.match(/\Aobligation/) && value
      return false unless other_licence.obligation.attributes[key] || soft_compatibility_acceptable
      # TODO: add a warning for soft compatibility
      # TODO: more specific checks for type of attribution, type of copyleft
    end

    # the other licence cannot grant any additional rights or permissions
    other_licence.right.attributes.each_pair do |key, value|
      next unless key.match(/\A(right|covers)/) && value
      return false unless licence.right.attributes[key]
    end

    # the other licence cannot remove any prohibitions (unless soft compatibility is acceptable,
    # such that the prohibitions can be included in a combined licence)
    other_licence.right.attributes.each_pair do |key, value|
      next unless key.match(/\A(prohibits)/) && !value
      return false if licence.right.attributes[key] && !soft_compatibility_acceptable
    end
  end

  def as_json(options = {})
    super( except: [ :id, :licence_id, :created_at, :updated_at ] )
  end
end
