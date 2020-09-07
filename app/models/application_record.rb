# frozen_string_literal: true

# Active Record is the M in MVC - the model - which is the layer of the system responsible
# for representing business data and logic. Active Record facilitates the creation and use
# of business objects whose data requires persistent storage to a database. It is an
# implementation of the Active Record pattern which itself is a description of an
# Object Relational Mapping system.
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def generate_slug(hash_string)
    Digest::SHA1.hexdigest(hash_string)[8..14] if hash_string
  rescue ActiveRecord::RecordNotUnique
    Digest::SHA1.hexdigest("#{hash_string}#{SecureRandom.uuid}")[8..14] if hash_string
  end

  protected

  def set_slug_from_id
    self.slug = generate_slug("#{SecureRandom.hex}#{id}")
  end
end
