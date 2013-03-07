namespace :licence_family do
  desc 'Generate a licence family tree (eg: rake licence_family:generate["Creative Commons","CC-BY-1.0","diff",0.8])'
  task :generate, [:title, :root_licence_id, :method, :diff_threshold] => :environment do |t, args|
    puts args
    require 'ruby-progressbar'
    require 'clip_similarity'

    # manually generate similarity matrix so we can output the progress
    puts 'Generating similarity matrix...'
    licences = Licence.all.map{|l| {id: l.id, filename: l.text.path } }
    if args[:method] == 'diff'
      progressbar = ProgressBar.create format: '%a |%B| %p%% %e', length: 80, smoothing: 0.5,
                                       total: licences.length*(licences.length-1)/2
      similarity_matrix = ClipSimilarity.calculate_with_diff(licences) { progressbar.increment }
    elsif args[:method] == 'td-idf'
      progressbar = ProgressBar.create format: '%a |%B| %p%% %e', length: 80, smoothing: 0.5,
                                       total: licences.length
      similarity_matrix = ClipSimilarity.calculate_with_tdidf(licences) { progressbar.increment }
    else
      fail "Unknown similarity method.  Permitted values are 'diff' and 'td-idf'."
    end

    # generate the tree
    puts 'Building tree...'
    root_licence = Licence.where(identifier: args[:root_licence_id]).first
    tree = FamilyTree.new(title: args[:title], diff_threshold: args[:diff_threshold])
    tree.build_tree(root_licence, similarity_matrix)

    # print out the tree
    puts 'Results:'
    def tree_print_recurse(node, depth = 0)
      puts "-" * depth + node.licence.identifier
      node.children.each do |child|
        tree_print_recurse(child, depth+1)
      end
    end
    tree_print_recurse(tree.root_node)
  end
end