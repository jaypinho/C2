module PropMixin

# Todo: We need the class name deduced from "self" to that this
# code can be reused on any :hasproperties class
  def setProp(p,v)
    ps = Property.where(:hasproperties_id => id,:hasproperties_type => self.class.name, :property => p)
    if ps.empty?
      p0 = Property.create(property: p,value: v)
    else
      p0 = ps[0]
      p0.value = v
      p0.save
    end

# TODO: we want to make this a single property, and also do a
# ruby encoding of the type someohow so we are not limiited to strings.
# We don't actually want multiple values for a single property---
# If we do, we will implement that ourselves in some other way.
      p0.update_attribute(:hasproperties,self)
  end
  def getProp(p)
    ps = Property.where(:hasproperties_id => id,:hasproperties_type => self.class.name, :property => p)
    if ps.empty?
      return nil
    else 
      return ps[0].value
    end
  end
end