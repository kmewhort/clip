module ScoreHelper

  # comparison group for comparing scores
  def comparison_group(score)
    licences = []
    if score.licence.maintainer_type == 'gov'
      licences = Licence.where(maintainer_type: 'gov')
    else
      licences += Licence.where(domain_content: true, maintainer_type: ['ngo','private']) if score.licence.domain_content
      licences += Licence.where(domain_software: true, maintainer_type: ['ngo','private']) if score.licence.domain_software
      licences += Licence.where(domain_data: true, maintainer_type: ['ngo','private']) if score.licence.domain_data
    end
    licences += benchmark_references(score)
    licences.map{|l| l.score}.uniq
  end

  # common licences to use as benchmarks
  def benchmark_references(score)
    benchmarks = []
    benchmarks += Licence.where(identifier: ['CC-BY-4.0', 'CC0-1.0']) if score.licence.domain_content
    benchmarks += Licence.where(identifier: ['BSD-2-Clause', 'GPL-3.0']) if score.licence.domain_software
    benchmarks += Licence.where(identifier: ['CC-BY-4.0', 'CC0-1.0', 'ODC-PDDL-1.0']) if score.licence.domain_data
    benchmarks.uniq
  end

  # use the government name for government licences; identifier for all others
  def score_column_title(score)
    if score.licence.maintainer_type == 'gov'
      score.licence.maintainer
    else
      score.licence.identifier
    end
  end
end