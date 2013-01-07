class CreateConflictOfLaws < ActiveRecord::Migration
  def change
    create_table :conflict_of_laws do |t|
      t.string :licence_id
      t.string :law_of
      t.string :forum_of

      t.timestamps
    end
  end
end
