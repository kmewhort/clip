namespace :compare do
  desc 'Generate a licence family tree (eg: rake compare:generate_family_tree["Creative Commons","CC-BY-1.0","diff",0.8])'
  task :generate_family_tree, [:title, :root_licence_id, :method, :diff_threshold] => :environment do |t, args|
    puts args

    root_licence = Licence.where(identifier: args[:root_licence_id]).first

    family = FamilyTree.new({
      title: args[:title],
      diff_method: args[:method],
      diff_threshold: args[:diff_threshold]
    })

    puts 'Generating similarity matrix and tree...'
    tree = family.build_tree(root_licence, true)

    # print out the tree
    puts 'Results:'
    puts tree.to_s

    # save
    puts 'Save (y/n)?'
    if STDIN.gets[0] == 'y'
      family.save
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

  desc 'Generate html diffs between licences within each family to /system/diff directory'
  task :generate_family_html_diffs, [:family_tree_id] => :environment do |t, args|
    puts args
    require 'ruby-progressbar'

    families = nil
    if !args[:family_tree_id].nil?
      families = FamilyTree.where(id: args[:family_tree_id])
    else
      families = FamilyTree.all
    end

    num_comparisons = families.map{|t| t.licences.length*t.licences.length}.reduce(:+)
    progressbar = ProgressBar.create format: '%a |%B| %p%% %e', length: 80, smoothing: 0.5,
                                     total: num_comparisons

    # simply hit every combination to cache the results
    families.each do |tree|
      tree.licences.each do |licence_a|
        tree.licences.each do |licence_b|
          licence_a.html_diff_with(licence_b)
          progressbar.increment
        end
      end
    end
  end
end