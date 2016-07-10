class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :subject
      t.string :body
      t.integer :article_id
      t.timestamps
    end
  end
end
