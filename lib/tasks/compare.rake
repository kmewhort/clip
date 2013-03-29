namespace :compare do
  desc 'Generate a licence family tree (eg: rake licence_family:generate["Creative Commons","CC-BY-1.0","diff",0.8])'
  task :generate_family_tree, [:title, :root_licence_id, :method, :diff_threshold] => :environment do |t, args|
    puts args
    require 'ruby-progressbar'
    require 'clip_similarity'

    # manually generate similarity matrix so we can output the progress
    puts 'Generating similarity matrix...'
    root_licence = Licence.where(identifier: args[:root_licence_id]).first
    licences = Licence.all.map{|l| {id: l.id, filename: l.text.path(:text) } }
    if args[:method] == 'diff'
      progressbar = ProgressBar.create format: '%a |%B| %p%% %e', length: 80, smoothing: 0.5,
                                       total: licences.length*(licences.length-1)/2
      similarity_matrix = ClipSimilarity.calculate_with_diff(licences) { progressbar.increment }
    elsif args[:method] == 'td-idf'
      progressbar = ProgressBar.create format: '%a |%B| %p%% %e', length: 80, smoothing: 0.5,
                                       total: licences.length
      similarity_matrix = ClipSimilarity.calculate_with_tdidf(licences) { progressbar.increment }
    elsif args[:method] == 'diffy'
      progressbar = ProgressBar.create format: '%a |%B| %p%% %e', length: 80, smoothing: 0.5,
                                       total: licences.length*(licences.length-1)/2
      similarity_matrix = ClipSimilarity.calculate_with_diffy(licences) { progressbar.increment }
    else
      fail "Unknown similarity method.  Permitted values are 'diff', 'td-idf' and 'diffy'"
    end

    # print out the similarity for root
    puts "Similarity for root licence (#{root_licence.identifier}):"
    similarity_matrix[root_licence.id].each do |id, val|
      puts "-#{Licence.find(id).identifier}: #{val.to_s}"
    end

    # generate the tree
    puts 'Building tree...'
    tree = FamilyTree.new(title: args[:title], diff_threshold: args[:diff_threshold])
    tree.build_tree(root_licence, similarity_matrix)

    # print out the tree
    puts 'Results:'
    def tree_print_recurse(node, depth = 0)
      puts "-" * depth + node.licence.identifier + ' (' + node.diff_score.to_s + ')'
      node.children.each do |child|
        tree_print_recurse(child, depth+1)
      end
    end
    tree_print_recurse(tree.root_node)

    # save
    puts 'Save (y/n)?'
    if STDIN.gets[0] == 'y'
      tree.save
    end
  end

  desc 'Generate html diffs between all licences to /system/diff directory'
  task :generate_html_diffs, [] => :environment do |t, args|
    puts args
    require 'ruby-progressbar'

    progressbar = ProgressBar.create format: '%a |%B| %p%% %e', length: 80, smoothing: 0.5,
                                     total: Licence.all.length*Licence.all.length

    # simply hit every combination to cache the results
    Licence.all.each do |licence_a|
      Licence.all.each do |licence_b|
        licence_a.html_diff_with(licence_b)
        progressbar.increment
      end
    end
  end
end