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

    task "update" do |t, args|
      k = Hermes::Index::INDEXES.find { |k| k.index_name == args[0].as(String) }
      if k
        k.not_nil!.update
        puts "Index is updated"
      else
        puts "No such index"
      end
    end

    task "create" do |t, args|
      k = Hermes::Index::INDEXES.find { |k| k.index_name == args[0].as(String) }
      if k
        k.not_nil!.create
        puts "Index is created"
      else
        puts "No such index"
      end
    end

    task "destroy" do |t, args|
      k = Hermes::Index::INDEXES.find { |k| k.index_name == args[0].as(String) }
      if k
        k.not_nil!.destroy
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
    task "add" do |t, args|
      Hermes::Cluster.add_alias(args[0].as(String), args[1].as(String))
    end

    task "remove" do |t, args|
      Hermes::Cluster.remove_alias(args[0].as(String), args[1].as(String))
    end
  end
end
