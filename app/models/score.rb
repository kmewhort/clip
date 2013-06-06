class Score < ActiveRecord::Base
  belongs_to :licence
  attr_accessible :openness, :licensee_legal_risk, :licensee_business_risk, :licensee_freedom, :licensor_legal_risk

  SCORE_WEIGHTS = {
      categories: {
          freedom: 1.0,
          legal_risk: 1.0,
          business_risk: 1.0
      },
      attributes: {
          core_rights: 13.0, # everything else only applies insofar as the core rights grant freedoms
          commercial_use: 1.0,
          attribution: 1.0,

          choice_of_forum: 0.75,
          choice_of_law: 0.75,
          warranty: 0.75,
          disclaimer: 0.75,
          indemnity: 2.0,

          unilateral_changes: 2.0,
          termination: 3.0
      }
  }

  # calculate the scores
  def score_licence
    calculate_licensee_legal_risk
    calculate_licensee_business_risk
    calculate_licensee_freedom
    calculate_licensor_legal_risk
    calculate_overall_openness
  end

  # >=22.5 = 3 stars (Gold), >=20 = 2 stars (Silver), >= 17.5 = 1 star (Bronze)
  def star_rating
    case
      when openness > 22.5
        3
      when openness > 20
        2
      when openness > 17.5
        1
      else
        0
    end
  end

  def openness_rank
    Score.count(conditions: "openness > #{self.openness}" ) + 1
  end

  def licensee_freedom_rank
    Score.count(conditions: "licensee_freedom > #{self.licensee_freedom}" ) + 1
  end

  def licensee_legal_risk_rank
    Score.count(conditions: "licensee_legal_risk > #{self.licensee_legal_risk}" ) + 1
  end

  def licensee_business_risk_rank
    Score.count(conditions: "licensee_business_risk > #{self.licensee_business_risk}" ) + 1
  end

  def licensor_business_risk_rank
    Score.count(conditions: "licensor_business_risk > #{self.licensor_business_risk}" ) + 1
  end

  private

  # overall measure of the "openness" of the licence (rather subjective, but suggestions for improvements are welcome!)
  def calculate_overall_openness
    self.openness = self.licensee_legal_risk    * SCORE_WEIGHTS[:categories][:legal_risk] +
        self.licensee_business_risk * SCORE_WEIGHTS[:categories][:business_risk] +
        self.licensee_freedom       * SCORE_WEIGHTS[:categories][:freedom]
  end

  # calculate a score of the legal risk to the licensee
  def calculate_licensee_legal_risk

    # Choice of forum affects legal risks because of the increased legal costs of defending against a lawsuit
    # in a foreign jurisdiction
    # - A forum selection clause (FSC) for the jurisdiction of the defendant generally introduces the lowest
    #   cost for the defendant, deterring lawsuits and legal risk
    # - An unspecified forum leaves the issue of forum up to the court to decide based on conflict of law
    #   rules, often involving considerable discretion such as with forum non conveniens considerations
    # - A FSC in favour of the licensor or pl will often bring the forum outside of the def's home
    #   jurisdictions (where this is different), introducing the highest degree of legal risk
    forum_score = nil
    if licence.conflict_of_law.forum_of == 'defendant'
      forum_score = 1.0
    elsif licence.conflict_of_law.forum_of == 'unspecified'
      forum_score = 0.5
    elsif licence.conflict_of_law.forum_of == 'licensor' ||
        licence.conflict_of_law.forum_of  == 'plaintiff' ||
        licence.conflict_of_law.forum_of  == 'specific'
      forum_score = 0
    else
      raise "Unrecognized value for conflict_of_law.forum_of"
    end

    # Choice of law affects legal risks because of the increased legal costs of retaining counsel
    # and experts familiar with a foreign law (it also introduces uncertainty of the legal risks in
    # using a license where foreign legal rules may apply)
    # - A choice of law clause (CLC) for the jurisdiction of the defendant generally introduces the lowest
    #   cost for the defendant, deterring lawsuits and legal risk
    # - An unspecified CSC leaves the issue of forum up to the court to decide based on conflict of law
    #   rules, often involving considerable discretion such as with forum non conveniens considerations
    # - A CLC in favour of the licensor or pl will often bring the forum outside of the def's home
    #   jurisdictions (where this is different), introducing the highest degree of legal risk
    # - A CLC in favour of the forum will match the legal risk for the forum
    law_score = nil
    if licence.conflict_of_law.law_of == 'defendant'
      law_score = 1.0
    elsif licence.conflict_of_law.law_of == 'unspecified'
      law_score = 0.5
    elsif licence.conflict_of_law.law_of == 'licensor' ||
        licence.conflict_of_law.law_of == 'plaintiff' ||
        licence.conflict_of_law.law_of == 'specific'
      law_score = 0
    elsif licence.conflict_of_law.law_of == 'forum'
      law_score = forum_score
    else
      raise "Unrecognized value for conflict_of_law.law_of"
    end

    # The two key warranties that licensor's can provide to reduce the licensee's legal risk are
    # 1. a warranty related to quality and accuracy, such as fitness for a purpose or merchantability; and/or
    # 2. a warranty of noninfringement of copyright (and other IP)
    # For #1, a form of this warranty is implied in many, if not most, jurisdictions. A disclaimer will negate it.
    # For #2, only some jurisdictions recognize an implied warranty of noninfringement.  Thus, a score for this is
    # applied only where such a warranty is explicitly provided.
    warranty_score = 0
    warranty_score += 0.5 if !licence.disclaimer.disclaimer_warranty
    warranty_score += 0.5 if licence.disclaimer.warranty_noninfringement

    # A disclaimer of liability generally prevents the licensee from making a claim against the licensor, even
    # where the licensor is legally at fault.
    disclaimer_score = licence.disclaimer.disclaimer_liability ? 0.0 : 1.0

    # Indemnication clauses obligate the licensee to defend and/or compensate the licensor for any 3rd party
    # lawsuits against the licensor (even if the fault is attributable to the licensor)
    indemnity_score = licence.disclaimer.disclaimer_indemnity ? 0.0 : 1.0

    # total score for legal risk to the licence user
    self.licensee_legal_risk =
        forum_score      * SCORE_WEIGHTS[:attributes][:choice_of_forum] +
            law_score        * SCORE_WEIGHTS[:attributes][:choice_of_law] +
            warranty_score   * SCORE_WEIGHTS[:attributes][:warranty] +
            disclaimer_score * SCORE_WEIGHTS[:attributes][:disclaimer] +
            indemnity_score  * SCORE_WEIGHTS[:attributes][:indemnity]
  end

  # calculate a score of the legal risk to the licensor
  def calculate_licensor_legal_risk
    # legal risk to the licencensor is the inverse of the risk to the licencee
    max_licensee_legal_risk =  SCORE_WEIGHTS[:attributes][:choice_of_forum] +
        SCORE_WEIGHTS[:attributes][:warranty] +
        SCORE_WEIGHTS[:attributes][:disclaimer] +
        SCORE_WEIGHTS[:attributes][:indemnity]

    self.licensor_legal_risk = max_licensee_legal_risk - self.licensee_legal_risk
  end

  # calculate a score of the business risk associated with a license (high score = low risk to the user)
  def calculate_licensee_business_risk
    # The ability of the licensor to unilaterally change the license terms (effectively revoking the original license)
    # creates a risk that the new license terms will not be amenable to the planned or existing business use case of a
    # licensee
    unilateral_change_score = licence.changes_to_term.licence_changes_effective_immediately ? 0 : 1.0

    # Where a license terminates on any violation of the terms, even an inadvertent breach could jeopordize
    # long-term use of the licensed content
    # Where there is no automatic termination, damages or specific performance are generally the only remedies
    # available (repudiation is only an option for fundamental breaches): this poses a lower business risk.
    # As well, where an automatic termination clause is attenuated by a chance to remedy a breach and automatically
    # reinstate the license, inadvertent breaches poses less of a business risk.
    # The right of the licensor to exercise discretion to revoke a license even where the licensee has not
    #  breached the terms poses the highest degree of business risk

    termination_risk_score = nil
    if licence.termination.termination_discretionary
      termination_risk_score = 0
    elsif licence.termination.termination_automatic
      termination_risk_score = 1.0 / 3.0
    else
      termination_risk_score = 1.0
    end

    termination_risk_score += (1.0 / 3.0) if licence.termination.termination_reinstatement

    self.licensee_business_risk =
        unilateral_change_score * SCORE_WEIGHTS[:attributes][:unilateral_changes] +
            termination_risk_score  * SCORE_WEIGHTS[:attributes][:termination]
  end

  # calculate a score of the degree of freedom that a licence grants (high score = more freedom);
  # (note: does not deal with attempts by a license to maintain freedoms (ie. copyleft or restrictions on TPMs)
  def calculate_licensee_freedom
    # With respect to data licenses, copyright is the only right that is likely to matter in most cases
    # (except in jurisdictions where SGDRs apply). This rights needs to be granted, or the license
    # effectively grants little
    if !licence.right.covers_copyright
      return (self.licensee_freedom = 0)
    end

    # the core rights that licenses typically grant and the right to use, modify & distribute
    core_rights_score = 0
    core_rights_score += (1.0/3.0) if licence.right.right_to_use_and_reproduce
    core_rights_score += (1.0/3.0) if licence.right.right_to_modify
    core_rights_score += (1.0/3.0) if licence.right.right_to_distribute

    # the above rights may be restricted to non-commercial purposes
    commercial_use_score = licence.right.prohibits_commercial_use ? 0 : 1.0

    # Notice and attribution requirements may reduce user freedom due to the burdens that complying with these
    # obligations can impose (they can become particularly problematic when combining data or content from
    # many sources)
    # Specific attribution imposes specific wording, which may not always be feasible depending on the
    # format (for example, a licensee could have difficulty complying with attribution using metadata for a large dataset)
    # Flexible attribution generally allows a licensee to attribute in a manner appropriate to the medium
    # A mere notice requirement usually only requires a reasonably accessible URL or other such notice to indicate
    # the particular licence under which the material falls
    notice_and_attribution_score = 1.0
    if licence.obligation.obligation_attribution
      notice_and_attribution_score -= (2.0 / 3.0)
      notice_and_attribution_score += (1.0 / 3.0) if licence.attribution_clause.attribution_type == 'flexible'
    end
    notice_and_attribution_score -= (1.0 / 3.0) if licence.obligation.obligation_notice

    self.licensee_freedom =
        core_rights_score            * SCORE_WEIGHTS[:attributes][:core_rights] +
            commercial_use_score         * SCORE_WEIGHTS[:attributes][:commercial_use] +
            notice_and_attribution_score * SCORE_WEIGHTS[:attributes][:attribution]
  end
end