# encoding: utf-8

class Posts
  def self.dispatcher(action)
    Proc.new do |env|
      self.new(env).send(action)
    end
  end

  def initialize(env)
    @env = env
  end

  def index
  end

  def new
    @form ||= PostForm.new
    @form.attributes[:method] = "POST"
  end
  
  def edit
    @form ||= PostForm.new
    @form.attributes[:method] = "PUT"
  end
  
  def create(raw_data)
    @form = PostForm.new(nil, raw_data)
    if @form.save
      redirect url(:posts)
    else
      self.new
    end
  end
  
  def update(id, raw_data)
    @form = PostForm.new(nil, raw_data)
    if @form.update(id)
      redirect url(:posts)
    else
      self.edit
    end
  end
end

map("/posts") do
  Posts.dispatcher(:index)
end
