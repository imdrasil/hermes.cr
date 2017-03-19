Sam.namespace "es" do
  namespace "index" do
    task "update_all" do
      Hermes::Index::INDEXES.each do |klass|
        klass.update
      end
    end

    task "create_all" do
      Hermes::Index::INDEXES.each do |klass|
        klass.create
      end
    end

    task "update" do |t, args|
      k = Hermes::Index::INDEXES.find { |k| k.index_name == args[0].as(String) }
      if k
        k.not_nil!.update
      else
        puts "No such index"
      end
    end

    task "create" do |t, args|
      k = Hermes::Index::INDEXES.find { |k| k.index_name == args[0].as(String) }
      if k
        k.not_nil!.create
      else
        puts "No such index"
      end
    end

    task "destroy" do |t, args|
      k = Hermes::Index::INDEXES.find { |k| k.index_name == args[0].as(String) }
      if k
        k.not_nil!.destroy
      else
        puts "No such index"
      end
    end

    task "destroy_all" do
      Hermes::Index::INDEXES.each do |k|
        k.destroy
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
