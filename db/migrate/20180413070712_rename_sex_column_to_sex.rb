class RenameSexColumnToSex < ActiveRecord::Migration[5.0]
  def change
    rename_column :users, :Sex, :sex
  end
end
