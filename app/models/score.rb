class Score < ActiveRecord::Base
  belongs_to @licence

  SCORE_WEIGHTS = {
      categories: {
        freedom: 1.0,
        legal_risk: 1.0,
        business_risk: 1.0
      },
      attributes: {
        core_rights: 3.0,
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

  def licence_user_legal_risk

    # Choice of forum affects legal risks because of the increased legal costs of defending against a lawsuit
    # in a foreign jurisdiction
    # - A forum selection clause (FSC) for the jurisdiction of the defendant generally introduces the lowest
    #   cost for the defendant, deterring lawsuits and legal risk
    # - An unspecified forum leaves the issue of forum up to the court to decide based on conflict of law
    #   rules, often involving considerable discretion such as with forum non conveniens considerations
    # - A FSC in favour of the licensor or pl will often bring the forum outside of the def's home
    #   jurisdictions (where this is different), introducing the highest degree of legal risk
    forum_score = 0
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
    law_score = 0
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
    disclaimer_score = !licence.disclaimer.disclaimer_liability ? 1.0 : 0

    # Indemnication clauses obligate the licensee to defend and/or compensate the licensor for any 3rd party
    # lawsuits against the licensor (even if the fault is attributable to the licensor)
    indemnity_score = !licence.disclaimer.disclaimer_indemnity ? 1.0 : 0

    # total score for legal risk to the licence user
    forum_score * SCORE_WEIGHTS[:attributes][:choice_of_forum] +
      law_score * SCORE_WEIGHTS[:attributes][:choice_of_law] +
      warranty_score * SCORE_WEIGHTS[:attributes][:warranty] +
      disclaimer_score * SCORE_WEIGHTS[:attributes][:disclaimer] +
      indemnity_score * SCORE_WEIGHTS[:attributes][:indemnity]
  end
end
