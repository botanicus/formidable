# encoding: utf-8

# text_field, text_area -> value = raw_data[key]
# raw_data == user: {}, tags: [{name: "Ruby"}]
# form = PostForm.new(@post.values, Author.all)
class PostForm < Formidable::Form
  namespace :post
  def initialize(raw_data, authors)
    super(raw_data)
    @authors = authors
  end

  text_field(:title)
    .validate_presence.
  text_field(:title) do
    validate_presence
  end
  
  check_box(:published)
  text_area
  
  group(:tydenni_menu) do
    check_box :svickova
    check_box :knedlo_zelo
    validate do
      self.fields.inject(0) do |sum, check_box|
        sum += 1 if check_box.selected?
        sum
      end
    end
  end
  
  select(:author) do
    @authors.each do |author|
      option selected: (author == raw_data[:author])
    end
  end
  
  submit(value: "Save")
  button(type: "submit") { "Save" }

  field(:password, id: "sdf") do
    validate_length (0..10)
    validate do
      form.password_confirmation == value
    end
  end

  field(:password_confirmation) do
    validate { form.password == value }
  end
  
  fields_for(:author) do
    field()
  end
  
  # <fieldset>
  # <legend>User</legend>
  # </fieldset>
  fieldset("User") do
    field(:name)
  end

  field(:tags, id: -> { |tag| "tag-#{tag.id}"}, array: true)
end
