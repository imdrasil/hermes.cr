require "spec"
require "../src/hermes"
require "./config"
require "./factories"

Hermes::Config.configure do |c|
  # c.default_index = "test_index"
end

Spec.before_each do
  query = {query: {match_all: {} of String => String}}
  PostRepository.delete_by_query(query)
  UserRepository.delete_by_query(query)
  ShapeRepository.delete_by_query(query)
  Hermes.refresh
end
