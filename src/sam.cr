Sam.namespace "es" do
  namespace "index" do
    task "update_all" do
      Hermes::Index::INDEXES.each do |klass|
        klass.update
        puts "Index #{klass} is updated"
      end
    end

    task "create_all" do
      Hermes::Index::INDEXES.each do |klass|
        if klass.exists?
          puts "Index #{klass} is already exists"
          klass.update.inspect
          puts "Index #{klass} is updated"
        else
          klass.create
          puts "Index #{klass} is created"
        end
      end
    end

    task "update" do |_, args|
      klass = Hermes::Index::INDEXES.find { |k| k.index_name == args[0].as(String) }
      if klass
        klass.not_nil!.update
        puts "Index is updated"
      else
        puts "No such index"
      end
    end

    task "create" do |_, args|
      klass = Hermes::Index::INDEXES.find { |k| k.index_name == args[0].as(String) }
      if klass
        klass.not_nil!.create
        puts "Index is created"
      else
        puts "No such index"
      end
    end

    task "destroy" do |_, args|
      klass = Hermes::Index::INDEXES.find { |k| k.index_name == args[0].as(String) }
      if klass
        klass.not_nil!.destroy
        puts "Index is updated"
      else
        puts "No such index"
      end
    end

    task "destroy_all" do
      Hermes::Index::INDEXES.each do |k|
        k.destroy
        puts "Index #{k} is destroyed"
      end
    end
  end

  namespace "alias" do
    task "add" do |_, args|
      Hermes::Cluster.add_alias(args[0].as(String), args[1].as(String))
    end

    task "remove" do |_, args|
      Hermes::Cluster.remove_alias(args[0].as(String), args[1].as(String))
    end
  end
end
