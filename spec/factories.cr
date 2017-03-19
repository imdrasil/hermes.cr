# TOOD: look to "like" field - default is brocken for hash
def build_post(title = "some title", user = "eddy", text = "tratata", tag = "es", created_at = Time.new, likes = 0)
  Post.new(title: title, user: user, text: text, tag: tag, created_at: created_at, likes: likes)
end

def create_post(**opts)
  p = build_post(**opts)
  PostRepository.save(p)
  p
end

def build_geo_point(lat = 1.0, lon = 1.0)
  ::Hermes::Types::GeoPoint.new({:lat => lat, :lon => lon})
end

def build_user(full_name = "kim", location = build_geo_point, photo = Hermes::Types::Binary.encode("photo"))
end
