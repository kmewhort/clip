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
end