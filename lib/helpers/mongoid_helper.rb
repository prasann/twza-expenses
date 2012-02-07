module MongoidHelper
  def declared_attributes
    self.attributes ? self.attributes.reject{|key,v| %w"_id updated_at created_at".include? key } : nil
  end
end