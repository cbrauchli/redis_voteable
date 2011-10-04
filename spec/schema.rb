# spec/schema.rb
ActiveRecord::Schema.define :version => 0 do
  create_table :voteable_models, :force => true do |t|
    t.string :name
  end

  create_table :voter_models, :force => true do |t|
    t.string :name
  end

  create_table :invalid_voteable_models, :force => true do |t|
    t.string :name
  end
end
