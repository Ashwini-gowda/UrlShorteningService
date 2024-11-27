class CreateUrlShorteners < ActiveRecord::Migration[8.0]
  def change
    create_table :url_shorteners do |t|
      t.string :original
      t.string :short

      t.timestamps
    end
  end
end
