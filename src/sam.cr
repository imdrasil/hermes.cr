Sam.namespace "es" do
  namespace "mapping" do
    task "update" do
      Hermes::Index::INDEXES.each do |klass|
        Hermes.client.put(klass.index_name, nil, klass.mapping.to_json)
      end
    end
  end
end
