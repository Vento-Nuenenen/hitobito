class MailLog < ActiveRecord::Migration

  def change

    create_table :mail_logs do |t|
      t.string :mail_from
      t.string :mail_subject
      t.string :mail_hash
      t.integer :status, default: 0
      t.string :mailing_list_name
      t.belongs_to :mailing_list, index: true
      t.timestamps(null: false)

      add_index :mail_logs, :mail_hash
    end

  end

end
